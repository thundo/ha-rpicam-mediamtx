# Changelog

## 0.2.0

- New `moq` option (default off) to turn on MediaMTX's MoQ server. Its ports (8892/tcp,
  8892/udp, 8893/udp) are declared but not exposed unless set in *Network*.
- Options are read from `/data/options.json` with jq and passed to MediaMTX as `MTX_*`
  environment overrides.

## 0.1.3

- Turn off MoQ, which MediaMTX 1.21 enables by default on ports 8892-8893. RTSP stays the only listener.

## 0.1.2

- Fix start-up failing with `mount: /dev/shm: permission denied`. MediaMTX's camera helper is now
  extracted to `/tmp/shm` (path rewritten in the binary at build time) instead of remounting
  `/dev/shm`, which needs `CAP_SYS_ADMIN`.
- Drop `full_access`: it only takes effect with protection mode off, and it does not grant the
  capability `mount` needed anyway. Protection mode can stay on.
- Grant access to the DMA heap (`/dev/dma_heap/*`), where the camera helper allocates frame buffers.

## 0.1.1

- Store icon, logo, description and documentation.

## 0.1.0

- First version: MediaMTX 1.21.1 `rpiCamera` source, RTSP only, path `cam`, 1920×1080 at 15 fps.
