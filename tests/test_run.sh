#!/bin/sh
# Tests the add-on options -> MediaMTX MTX_* mapping in rpicam_mediamtx/run.sh.
# run.sh is executed against fixture options with a fake mediamtx that prints its
# MTX_* environment, so no camera and no MediaMTX are needed.
#
# Needs jq. Without it locally, run it in a container:
#   docker run --rm -v "$PWD":/src -w /src alpine sh -c 'apk add -q jq && sh tests/test_run.sh'
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
FAILED=0

cat >"$WORK/mediamtx" <<'EOF'
#!/bin/sh
env | grep '^MTX_' | sort
EOF
chmod +x "$WORK/mediamtx"

run() { # $1: options JSON
    printf '%s' "$1" >"$WORK/options.json"
    OPTIONS="$WORK/options.json" MEDIAMTX="$WORK/mediamtx" sh "$ROOT/rpicam_mediamtx/run.sh" 2>&1
}

check() { # $1: name, $2: options JSON, $3: expected output
    got=$(run "$2")
    if [ "$got" = "$3" ]; then
        echo "ok   $1"
    else
        echo "FAIL $1"
        printf '%s\n' "$3" >"$WORK/want"
        printf '%s\n' "$got" >"$WORK/got"
        diff -u "$WORK/want" "$WORK/got" | sed 's/^/     /'
        FAILED=1
    fi
}

check_fails() { # $1: name, $2: options JSON, $3: expected substring of the error
    if got=$(run "$2"); then
        echo "FAIL $1 (exit 0)"
        FAILED=1
    elif printf '%s' "$got" | grep -qF "$3"; then
        echo "ok   $1"
    else
        echo "FAIL $1: error does not mention '$3': $got"
        FAILED=1
    fi
}

DEFAULTS='"resolution":"1920x1080","fps":15,"bitrate":5000,"hflip":false,"vflip":false,"timestamp":false,"log_level":"info","moq":false'

check "defaults" "{$DEFAULTS}" "MTX_LOGLEVEL=info
MTX_MOQ=false
MTX_PATHS_CAM_RPICAMERABITRATE=5000000
MTX_PATHS_CAM_RPICAMERAFPS=15
MTX_PATHS_CAM_RPICAMERAHEIGHT=1080
MTX_PATHS_CAM_RPICAMERAHFLIP=false
MTX_PATHS_CAM_RPICAMERAIDRPERIOD=30
MTX_PATHS_CAM_RPICAMERATEXTOVERLAYENABLE=false
MTX_PATHS_CAM_RPICAMERAVFLIP=false
MTX_PATHS_CAM_RPICAMERAWIDTH=1920"

check "everything set" '{"resolution":"1640x1232","fps":10,"bitrate":2500,"hflip":true,"vflip":true,
  "timestamp":true,"log_level":"debug","moq":true,
  "brightness":0.1,"contrast":1.5,"saturation":0,"sharpness":2,"ev":-1.5,
  "awb":"daylight","exposure":"long","denoise":"cdn_fast","flicker":"50hz",
  "rtsp_username":"ha","rtsp_password":"s3cret"}' "MTX_AUTHINTERNALUSERS_0_PASS=s3cret
MTX_AUTHINTERNALUSERS_0_USER=ha
MTX_LOGLEVEL=debug
MTX_MOQ=true
MTX_PATHS_CAM_RPICAMERAAWB=daylight
MTX_PATHS_CAM_RPICAMERABITRATE=2500000
MTX_PATHS_CAM_RPICAMERABRIGHTNESS=0.1
MTX_PATHS_CAM_RPICAMERACONTRAST=1.5
MTX_PATHS_CAM_RPICAMERADENOISE=cdn_fast
MTX_PATHS_CAM_RPICAMERAEV=-1.5
MTX_PATHS_CAM_RPICAMERAEXPOSURE=long
MTX_PATHS_CAM_RPICAMERAFLICKERPERIOD=10000
MTX_PATHS_CAM_RPICAMERAFPS=10
MTX_PATHS_CAM_RPICAMERAHEIGHT=1232
MTX_PATHS_CAM_RPICAMERAHFLIP=true
MTX_PATHS_CAM_RPICAMERAIDRPERIOD=20
MTX_PATHS_CAM_RPICAMERASATURATION=0
MTX_PATHS_CAM_RPICAMERASHARPNESS=2
MTX_PATHS_CAM_RPICAMERATEXTOVERLAY=%Y-%m-%d %H:%M:%S
MTX_PATHS_CAM_RPICAMERATEXTOVERLAYENABLE=true
MTX_PATHS_CAM_RPICAMERAVFLIP=true
MTX_PATHS_CAM_RPICAMERAWIDTH=1640"

check "flicker 60hz" "{$DEFAULTS,\"flicker\":\"60hz\"}" "MTX_LOGLEVEL=info
MTX_MOQ=false
MTX_PATHS_CAM_RPICAMERABITRATE=5000000
MTX_PATHS_CAM_RPICAMERAFLICKERPERIOD=8333
MTX_PATHS_CAM_RPICAMERAFPS=15
MTX_PATHS_CAM_RPICAMERAHEIGHT=1080
MTX_PATHS_CAM_RPICAMERAHFLIP=false
MTX_PATHS_CAM_RPICAMERAIDRPERIOD=30
MTX_PATHS_CAM_RPICAMERATEXTOVERLAYENABLE=false
MTX_PATHS_CAM_RPICAMERAVFLIP=false
MTX_PATHS_CAM_RPICAMERAWIDTH=1920"

check_fails "username without password" "{$DEFAULTS,\"rtsp_username\":\"ha\"}" "rtsp_username and rtsp_password"
check_fails "password without username" "{$DEFAULTS,\"rtsp_password\":\"x\"}" "rtsp_username and rtsp_password"

exit $FAILED
