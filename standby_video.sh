#!/bin/bash

/usr/bin/gst-launch-1.0 -v \
videotestsrc pattern=black is-live=true ! \
video/x-raw,width=1280,height=480,framerate=15/1 ! \
textoverlay text='Waiting for Cameras...' valignment=center halignment=center font-desc='Sans 32' ! \
videoconvert ! \
v4l2h264enc extra-controls='controls,video_bitrate=1200000,h264_i_frame_period=15' ! \
'video/x-h264,level=(string)4,profile=baseline' ! \
h264parse config-interval=1 ! \
rtspclientsink location=rtsp://127.0.0.1:8554/standby protocols=tcp
