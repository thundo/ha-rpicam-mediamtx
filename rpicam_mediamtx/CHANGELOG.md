# Changelog

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
