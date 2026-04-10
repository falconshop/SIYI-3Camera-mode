#!/bin/bash

CAM1="192.168.144.24"
CAM2="192.168.144.23"
PORT="8554"

# 1. Fast Network Check (Initial Boot)
nc -z -w 2 $CAM1 $PORT
CAM1_ONLINE=$?

nc -z -w 2 $CAM2 $PORT
CAM2_ONLINE=$?

# 2. Check for Total Failure
if [ $CAM1_ONLINE -ne 0 ] && [ $CAM2_ONLINE -ne 0 ]; then
    echo "Both cameras are unreachable. Failing."
    exit 1
fi

# 3. Base Pipeline (Added background=1 so the compositor defaults to black, not checkerboard)
PIPELINE="/usr/bin/gst-launch-1.0 -v \
compositor name=comp background=1 sink_0::xpos=0 sink_1::xpos=640 ! \
video/x-raw,width=1280,height=480,format=I420,framerate=15/1 ! \
videoconvert ! \
v4l2h264enc extra-controls='controls,video_bitrate=1200000,h264_i_frame_period=15' ! \
'video/x-h264,level=(string)4,profile=baseline' ! \
h264parse config-interval=1 ! \
rtspclientsink location=rtsp://127.0.0.1:8554/video1 protocols=tcp"

# 4. Build Camera 1 Branch
if [ $CAM1_ONLINE -eq 0 ]; then
    PIPELINE="$PIPELINE \
    rtspsrc location=rtsp://$CAM1:$PORT/main.264 latency=0 protocols=tcp timeout=5000000 ! \
    rtph265depay ! h265parse ! avdec_h265 ! videoconvert ! videoscale ! \
    video/x-raw,width=640,height=480 ! \
    queue leaky=2 max-size-buffers=1 ! comp.sink_0"
else
    PIPELINE="$PIPELINE \
    videotestsrc pattern=black is-live=true ! \
    video/x-raw,width=640,height=480,framerate=15/1 ! \
    textoverlay text='Camera 1 unreachable' valignment=center halignment=center font-desc='Sans 32' ! \
    videoconvert ! queue leaky=2 max-size-buffers=1 ! comp.sink_0"
fi

# 5. Build Camera 2 Branch
if [ $CAM2_ONLINE -eq 0 ]; then
    PIPELINE="$PIPELINE \
    rtspsrc location=rtsp://$CAM2:$PORT/main.264 latency=0 protocols=tcp timeout=5000000 ! \
    rtph265depay ! h265parse ! avdec_h265 ! videoconvert ! videoscale ! \
    video/x-raw,width=640,height=480 ! \
    queue leaky=2 max-size-buffers=1 ! comp.sink_1"
else
    PIPELINE="$PIPELINE \
    videotestsrc pattern=black is-live=true ! \
    video/x-raw,width=640,height=480,framerate=15/1 ! \
    textoverlay text='Camera 2 unreachable' valignment=center halignment=center font-desc='Sans 32' ! \
    videoconvert ! queue leaky=2 max-size-buffers=1 ! comp.sink_1"
fi

# 6. Execute GStreamer in the BACKGROUND
eval $PIPELINE &
GST_PID=$!

# Ensure GStreamer is killed if systemd stops this bash script
trap "kill $GST_PID 2>/dev/null; exit" SIGINT SIGTERM

# 7. The TWO-WAY Watchdog Loop
while true; do
    sleep 3

    # Check A: Did GStreamer crash completely?
    if ! kill -0 $GST_PID 2>/dev/null; then
        echo "GStreamer process died. Exiting to trigger systemd restart."
        exit 1
    fi

    # Check B: Monitor Camera 1 for ANY state change (Wake up OR Die)
    nc -z -w 1 $CAM1 $PORT
    CURRENT_CAM1=$?
    if [ $CAM1_ONLINE -ne $CURRENT_CAM1 ]; then
        echo "State change detected on Camera 1! Restarting pipeline."
        kill $GST_PID 2>/dev/null
        exit 1
    fi

    # Check C: Monitor Camera 2 for ANY state change (Wake up OR Die)
    nc -z -w 1 $CAM2 $PORT
    CURRENT_CAM2=$?
    if [ $CAM2_ONLINE -ne $CURRENT_CAM2 ]; then
        echo "State change detected on Camera 2! Restarting pipeline."
        kill $GST_PID 2>/dev/null
        exit 1
    fi
done