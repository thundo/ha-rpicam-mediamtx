# The -rpi image bundles libcamera and the camera helper (mtxrpicam) on a Debian base.
FROM bluenviron/mediamtx:1.21.1-rpi

# MediaMTX extracts mtxrpicam to a hardcoded /dev/shm/mediamtx-rpicamera-* and executes it
# from there. The Supervisor mounts /dev/shm noexec, and remounting it would need
# CAP_SYS_ADMIN, which no add-on option grants short of `privileged: [SYS_ADMIN]`.
# Rewrite the path to /tmp/shm (on the image's own filesystem, so exec is allowed): same
# length, so the binary's layout is untouched. The build fails if the string is not
# found exactly once, which is what a MediaMTX bump that moves it would look like.
RUN perl -pi -e 's|/dev/shm/mediamtx-rpicamera-|/tmp/shm/mediamtx-rpicamera-|g' /mediamtx \
    && [ "$(grep -c -a '/tmp/shm/mediamtx-rpicamera-' /mediamtx)" = 1 ] \
    && [ "$(grep -c -a '/dev/shm/mediamtx-rpicamera-' /mediamtx)" = 0 ] \
    && mkdir -p /tmp/shm

# jq reads the add-on options in run.sh.
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY mediamtx.yml /etc/mediamtx/mediamtx.yml
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
