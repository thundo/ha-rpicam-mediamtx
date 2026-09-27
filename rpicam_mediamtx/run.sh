#!/bin/sh
set -e

# Add-on options map onto MediaMTX's MTX_<KEY> environment overrides,
# which take precedence over mediamtx.yml.
OPTIONS=/data/options.json

MTX_MOQ=$(jq -r '.moq' "$OPTIONS")
export MTX_MOQ

exec /mediamtx /etc/mediamtx/mediamtx.yml
