# Raspberry Pi Camera add-on for Home Assistant OS

A Home Assistant add-on that streams a Raspberry Pi CSI camera over RTSP, using
[MediaMTX](https://mediamtx.org/docs/publish/raspberry-pi-cameras)'s `rpiCamera` source on the
modern libcamera stack. It wraps the official `bluenviron/mediamtx:<version>-rpi` image, which
bundles libcamera and the hardware H.264 encoder helper, so nothing is compiled here.

Tested target: Raspberry Pi 4, HAOS, Camera Module v2.1 (IMX219).

## Host prerequisite (outside this repo)

HAOS does not enable the camera. On the host, `/mnt/boot/config.txt` needs the sensor overlay,
and the legacy stack must stay off:

```
#start_x=1
dtoverlay=imx219
```

After a reboot, `dmesg | grep imx219` must show no `failed to read chip id`, and `/dev/video0` plus
`/dev/v4l-subdev0` must exist. `-EREMOTEIO` / `failed to read chip id` means the sensor does not
answer on I2C: ribbon in the `DISPLAY` connector, or inserted the wrong way round.

## Install

1. *Settings → Add-ons → Add-on Store → ⋮ → Repositories*, add
   `https://github.com/thundo/ha-rpicam-mediamtx`.
2. Install **Raspberry Pi Camera (MediaMTX)** and start it. The first start builds the image on
   the Pi.
3. Note the add-on **hostname** on its Info page.
4. Add a *Generic Camera* with stream source `rtsp://<hostname>:8554/cam`.

## Security

Only `read` on path `cam` is allowed, without credentials: nobody can publish. Port 8554 is not
exposed on the host by default, so the stream is reachable only from Home Assistant and other
add-ons. Setting a host port in the add-on's *Network* section exposes it unauthenticated to the LAN.
