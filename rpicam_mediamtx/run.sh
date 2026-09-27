#!/bin/sh
set -eu

# Add-on options map onto MediaMTX's MTX_<KEY> environment overrides, which take
# precedence over mediamtx.yml. OPTIONS and MEDIAMTX are overridable for tests.
OPTIONS=${OPTIONS:-/data/options.json}
MEDIAMTX=${MEDIAMTX:-/mediamtx}
CAM=MTX_PATHS_CAM_RPICAMERA

# Prints the option's value, or nothing when it is unset. `// empty` would also
# swallow `false`, hence the explicit null test.
opt() {
    jq -r --arg k "$1" 'if .[$k] == null then empty else .[$k] end' "$OPTIONS"
}

# Exports $1=<value of option $2>, only when the option is set.
map() {
    value=$(opt "$2")
    if [ -n "$value" ]; then
        export "$1=$value"
    fi
}

resolution=$(opt resolution)
export "${CAM}WIDTH=${resolution%x*}" "${CAM}HEIGHT=${resolution#*x}"

fps=$(opt fps)
export "${CAM}FPS=$fps"
# A viewer can only start decoding on a keyframe: one every 2 s bounds how long
# the live view stays black when it opens, instead of MediaMTX's 60 frames.
export "${CAM}IDRPERIOD=$((fps * 2))"

export "${CAM}BITRATE=$(($(opt bitrate) * 1000))"

map "${CAM}HFLIP" hflip
map "${CAM}VFLIP" vflip

map "${CAM}TEXTOVERLAYENABLE" timestamp
if [ "$(opt timestamp)" = true ]; then
    export "${CAM}TEXTOVERLAY=%Y-%m-%d %H:%M:%S"
fi

map "${CAM}BRIGHTNESS" brightness
map "${CAM}CONTRAST" contrast
map "${CAM}SATURATION" saturation
map "${CAM}SHARPNESS" sharpness
map "${CAM}EV" ev
map "${CAM}AWB" awb
map "${CAM}EXPOSURE" exposure
map "${CAM}DENOISE" denoise

# Mains flicker shows up as rolling bands under artificial light; the exposure
# has to be a multiple of the light's period, i.e. half the mains period.
case "$(opt flicker)" in
    50hz) export "${CAM}FLICKERPERIOD=10000" ;;
    60hz) export "${CAM}FLICKERPERIOD=8333" ;;
esac

user=$(opt rtsp_username)
pass=$(opt rtsp_password)
if [ -n "$user" ] || [ -n "$pass" ]; then
    if [ -z "$user" ] || [ -z "$pass" ]; then
        echo "rtsp_username and rtsp_password must be set together" >&2
        exit 1
    fi
    # Replaces the anonymous reader of mediamtx.yml; its read-only permission on
    # `cam` is kept.
    export MTX_AUTHINTERNALUSERS_0_USER="$user" MTX_AUTHINTERNALUSERS_0_PASS="$pass"
fi

map MTX_LOGLEVEL log_level
map MTX_MOQ moq

exec "$MEDIAMTX" /etc/mediamtx/mediamtx.yml
