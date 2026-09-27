#!/bin/sh
set -e

# MediaMTX extracts mtxrpicam to /dev/shm/mediamtx-rpicamera-* (hardcoded) and runs it
# from there, but Docker mounts /dev/shm noexec.
mount -o remount,exec /dev/shm

exec /mediamtx /etc/mediamtx/mediamtx.yml
