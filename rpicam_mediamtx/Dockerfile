# The -rpi image bundles libcamera and the camera helper (mtxrpicam) on a Debian base.
FROM bluenviron/mediamtx:1.21.1-rpi

COPY mediamtx.yml /etc/mediamtx/mediamtx.yml
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
