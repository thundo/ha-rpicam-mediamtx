# Raspberry Pi Camera (MediaMTX)

Live stream from the Raspberry Pi CSI camera that is plugged into the Pi running Home Assistant OS.

![Supports aarch64][aarch64-shield] ![Stage: experimental][stage-shield]

- **Modern camera stack**: libcamera, the stack Raspberry Pi maintains today, not the
  deprecated legacy one (`start_x=1` / MMAL).
- **Hardware H.264**: the Pi's VideoCore encodes, not the CPU that runs your house.
- **Nothing compiled**: a thin wrapper around the official MediaMTX `-rpi` image, pinned to a release.
- **Private by default**: RTSP is reachable only from Home Assistant and other add-ons, read-only.
- **Configurable from the UI**: resolution, frame rate, mirroring, timestamp, image tuning, credentials.

In Home Assistant, add a *Generic Camera* pointing at the stream; go2rtc serves it to the
dashboard over WebRTC.

⚠️ The camera must first be enabled on the host (`dtoverlay` in `config.txt`). See the
**Documentation** tab.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[stage-shield]: https://img.shields.io/badge/stage-experimental-orange.svg
