# Raspberry Pi Camera (MediaMTX)

Streams the CSI camera attached to the Home Assistant host as RTSP, using
[MediaMTX](https://mediamtx.org/docs/publish/raspberry-pi-cameras)'s `rpiCamera` source.

Tested on: Raspberry Pi 4, Home Assistant OS, Camera Module v2.1 (IMX219).

## 1. Enable the camera on the host

Home Assistant OS does not load a camera driver on its own. The overlay has to go into the
host's boot configuration, which lives **outside** `/config` and outside any backup, so write it
down somewhere: a reinstall loses it.

Open a shell **on the host** (the SSH add-on with protection mode off, or the debug port 22222),
then:

```sh
mount -o remount,rw /mnt/boot
vi /mnt/boot/config.txt      # add the line below, under [all]
mount -o remount,ro /mnt/boot
```

```
dtoverlay=imx219
```

Use the overlay that matches your sensor (`ov5647` for v1, `imx219` for v2, `imx708` for v3,
`imx477` for the HQ camera). **Do not** also enable `start_x=1`: that is the legacy stack, and it
takes the camera away from libcamera.

Reboot the host (power it off instead if you also touched the ribbon), then check:

```sh
dmesg | grep -i imx219          # no "failed to read chip id"
ls /dev/video0 /dev/v4l-subdev0 # both must exist
```

## 2. Install and start the add-on

The first start builds the image on the Pi and takes a few minutes. The log should show
MediaMTX opening the camera; the stream path is `cam`.

## 3. Add the camera to Home Assistant

*Settings → Devices & services → Add integration → Generic Camera*, with:

- **Stream source**: `rtsp://<hostname>:8554/cam`, where `<hostname>` is shown on this add-on's
  *Info* page.
- **Still image URL**: leave empty; Home Assistant takes snapshots from the stream.
- **RTSP transport**: TCP.

Home Assistant's built-in go2rtc then serves the stream to the dashboard over WebRTC.

## Options

| Option | Default | Effect |
|---|---|---|
| `resolution` | `1920x1080` | Output size. Presets stop at 1920×1080, the most the Pi 4 hardware H.264 encoder takes; anything bigger would be encoded in software on the CPU that runs Home Assistant. On the IMX219, 1920×1080 is a centre crop; `1640x1232` shows the whole sensor at about the same pixel count. |
| `fps` | `15` | Frames per second, 1–30. |
| `bitrate` | `5000` | H.264 target bitrate, kbit/s. |
| `hflip` / `vflip` | `false` | Mirror left–right / flip upside down. Both together rotate by 180°. |
| `timestamp` | `false` | Date and time on every frame, in Home Assistant's time zone. |
| `brightness`, `contrast`, `saturation`, `sharpness`, `ev` | unset | Image tuning. Unset keeps MediaMTX's defaults (0, 1, 1, 1, 0). |
| `awb`, `exposure`, `denoise` | unset | White balance, exposure mode and ISP denoise. Unset means `auto`, `normal`, `off`. |
| `flicker` | unset | `50hz` / `60hz` removes the rolling bands artificial light causes. |
| `rtsp_username` / `rtsp_password` | unset | Require credentials to read the stream. Set both, then add them to the Generic Camera too. |
| `log_level` | `info` | MediaMTX log verbosity. |
| `moq` | `false` | Also serve the stream over MoQ (Media over QUIC) for browsers using WebTransport. Home Assistant does not use it. Reaching it from the LAN also needs the 8892/8893 ports set under *Network*. |

The unset ones sit under *Show unused optional configuration options*.

A keyframe is sent every 2 seconds whatever the frame rate: a viewer can only start decoding on
one, so this bounds how long the live view stays black when it opens.

## Network and security

- Port 8554 is **not** exposed on the host by default. Home Assistant reaches the add-on over the
  internal Supervisor network, so it does not need it.
- Nothing can be published to the stream. Reading it needs no credentials unless
  `rtsp_username` / `rtsp_password` are set, so set them before giving 8554 a host port under
  *Network* (to open the stream in VLC, for example): otherwise anyone on your LAN can watch it.

## Current limits

- One camera, path `cam`.
- Live view only: no recording, no motion detection.

## Troubleshooting

| Symptom | Cause |
|---|---|
| `dmesg`: `failed to read chip id`, `-EREMOTEIO` | The sensor does not answer on I2C. The ribbon is in the `DISPLAY` connector, or it is in the wrong way round (blue side towards Ethernet/USB on a Pi 4), or the small sensor connector on the camera board has come loose. |
| No `/dev/video0` and no error in `dmesg` | The overlay was not loaded: check `config.txt` and that it sits under `[all]`. |
| `mount: /dev/shm: permission denied` | Version 0.1.1 or earlier. Update: 0.1.2 no longer remounts anything. |
| Log mentions `dma_heap` | The DMA heap device has a name not listed under `devices` in `config.yaml`. Check `ls /dev/dma_heap/` on the host. |
| Add-on runs but reports no camera | Another process owns the camera, typically `start_x=1` still active on the host. |
