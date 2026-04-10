# SIYI 3Camera mode
SIYI UniRC7 조종기에 동시에 3개의 카메라를 보기 위한 상세한 방법을 안내합니다.

이 매뉴얼은 https://www.falconshop.co.kr 에서 작성하였습니다.


## SIYI UniRC7 화면
SIYI UniRC7 의 AirUnit 은 기본적으로 2개의 Ip 카메라 연결을 지원합니다.
만약 3개의 카메라를 동시에 시청해야 할 필요가 있다면, 이 모드를 사용할 수 있습니다.
이 모드를 사용할 경우 아래와 같이 3개의 영상을 동시에 실시간으로 시청할 수 있습니다. 
![SIYI UniRC7](https://github.com/falconshop/SIYI-3Camera-mode/blob/main/SIYI%20UniRC7%203CAM.jpg)
이 모드의 핵심은, 3개 중 2개의 카메라를 RaspberryPi 를 이용하여 하나의 영상으로 합성 후 다시 AirUnit 으로 송출하여, 결과적으로 AirUnit 은 2개의 카메라가 장착되어 있다고 인식하게 하는 것입니다. 


## 개요
![Map](https://github.com/falconshop/SIYI-3Camera-mode/blob/main/Map.jpg)
이 매뉴얼에서는 [SIYI A2 Mini](https://www.falconshop.co.kr/shop/goods/goods_view.php?goodsno=100074742) 2개와 Sony 카메라 1개를 사용했으며, Sony 카메라를 AirUnit 에 연결하기 위해 [SIYI HDMI to IP Converter](https://www.falconshop.co.kr/shop/goods/goods_view.php?goodsno=100077072) 를 사용했습니다. 동일한 제품이 아니더라도 상관 없으며, 꼭 SIYI 제품이 아니더라도 IP 주소를 192.168.144.x 로 변경할 수 있는 IP 카메라는 모두 사용이 가능합니다. 



## 준비물
1. SIYI IP 카메라 3개
2. RaspberryPi 4b (+ MicroSD Card)
3. IP Hub (IPTime H905)
4. DIY LAN 케이블 3개
5. DIY Molex 2.54mm Connectors, JST BEC Connectors, XT60, XT30 등 연결 커넥터류



## 카메라 IP 설정
SIYI 카메라들의 기본 IP 주소는 192.168.144.25 입니다. 

2개의 카메라가 장착 될 경우, 2nd 카메라의 IP 주소는 192.168.144.26 으로 변경되어야 합니다. 

우리는 3개의 카메라를 사용하지만, 실질적으로 RaspberryPi 가 하나의 카메라로서 인식되어야 하기 때문에, IP 주소는 아래와 같이 설정되어야 합니다.

- RaspberryPi : 192.168.144.25
- SIYI A2 Mini 1 : 192.168.144.23
- SIYI A2 Mini 2 : 192.168.144.24
- SIYI HDMI to IP Converter : 192.168.144.26

위와 같이 설정하여 IP 주소가 충돌되지 않도록 합니다. 



## SIYI A2 Mini 카메라 커넥터 변경
![A2 Connector modify](https://github.com/falconshop/SIYI-3Camera-mode/blob/main/A2-Connector.jpg)
A2 Mini 의 커넥터는 GH1.25 8핀 규격으로, SIYI Air Unit 에 바로 연결할 수 있게 제작되어 있습니다.
그러나 우리는 이것을 RaspberryPi 에 연결해야 하므로, 커넥터를 변경해야 합니다.
사용의 편의를 위해 LAN 신호는 Molex 2.54mm 4핀으로 변경했으며, 12V 전원 케이블은 JST BEC 케이블로 작업했습니다.
12V 전원 케이블은 12V 아답터(또는 3S Lipo 배터리)에 연결하며, LAN 신호는 LAN 케이블을 연결해서 RaspberryPi 의 LAN Port 에 연결합니다.

A2 Mini 의 Connector 변경시 전선 색상에 주의하세요. 카메라의 설명서에 적혀있는 실제 제품의 색상이 맞지 않으므로, 색상으로 구분하지 말고 반드시 핀의 순서를 보고 구분하세요. 
혼동을 방지하기 위해 순정 상태에서 Connector 의 사진을 미리 하나 찍어 두시는 것을 권장드립니다.

![A2 Connect to device](https://github.com/falconshop/SIYI-3Camera-mode/blob/main/A2-Connect-to-device.jpg)
PWM 케이블은 A2 Mini 의 Gimbal 을 Tilt 방향으로 제어하기 위한 것으로, 영상 송출과는 관계가 없기 때문에 Gimbal 을 제어할 필요가 없다면 신경쓰지 않으셔도 됩니다. 여기서는 PWM 케이블에 Molex 2.54mm 3핀 헤더로 변경하였으며, Pixhawk 의 Aux Out 에 연결해서 제어하였습니다.




## SIYI A2 Mini 카메라 : IP 변경
A2 Mini 카메라 2개의 IP 주소를 각각 23, 24 로 변경해야 합니다. SIYI 에서 제공하는 IP 변경툴이 없으므로, 우리가 직접 A2 Mini 카메라의 [IP 주소를 변경하는 툴](<https://github.com/falconshop/SIYI-3Camera-mode/blob/main/set_siyi_ip.py>)을 만들었습니다.

IP 변경 툴 파일을 RaspberryPi 에 넣고, IP 주소를 변경할 SIYI A2 Mini 카메라를 LAN 케이블을 이용해서 RaspberryPi 에 연결합니다. 그리고 RaspberryPi 및 A2 Mini 카메라에 전원을 공급합니다. 

위의 IP 변경 툴 파일은 아래와 같이 사용합니다.

    python3 set_siyi_ip.py -t 변경전 IP 주소 -n 새로운 IP 주소

SIYI A2 Mini 카메라의 기본 IP 주소는 192.168.144.25 이므로, 다음과 같이 입력하여 IP 를 변경합니다.

1번 카메라 :

    python3 set_siyi_ip.py -t 192.168.144.25 -n 192.168.144.23

2번 카메라 : 

    python3 set_siyi_ip.py -t 192.168.144.25 -n 192.168.144.24



## SIYI HDMI to IP Converter : IP 변경
상세 이미지가 있는 전체 매뉴얼은 [이 링크](<https://siyi.biz/siyi_file/Sky%20end%20card%20HDMI/Air%20Unit%20HDMI%20Converter%20User%20Manual_En%20v1.0.pdf>) 를 참고하세요.
MicroSD 카드에 setup.txt 파일을 생성합니다. 파일 내용은 아래와 같이 작성합니다.

    [NET_CONFIG]
    IP = 192.168.144.26

작성한 파일을 SD 카드에 저장하고 IP Converter 에 삽입합니다. 그리고 IP Converter 에 전원을 넣고 약 5분 정도 기다립니다.

IP 가 제대로 변경되었는지 확인하기 위해 SD 카드를 빼서 확인합니다. curip.txt 파일이 자동으로 생성되어 있으며, 해당 파일에 아래와 같이 변경된 IP 주소가 적혀있으면 정상적으로 변경된 것입니다.

    [NET_CONFIG]
    IP = 192.168.144.26



## 전체 배선
이제 아래의 배선도와 사진을 참고하여 모든 카메라와 RaspberryPi, IP Hub 를 연결합니다. 
![Map](https://github.com/falconshop/SIYI-3Camera-mode/blob/main/Map.jpg)
![Connect1](https://github.com/falconshop/SIYI-3Camera-mode/blob/main/Connect1.jpg)
![Connect2](https://github.com/falconshop/SIYI-3Camera-mode/blob/main/Connect2.jpg)



# RaspberryPi 작업
## 1. 필수 패키지 설치
카메라의 H.265 피드를 소프트웨어 방식으로 디코딩하려면 GStreamer 핵심 라이브러리, V4L2 하드웨어 플러그인, 그리고 libav 제품군이 필요합니다.
    
    sudo apt update
    sudo apt install -y gstreamer1.0-tools gstreamer1.0-libav gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly libgstrtspserver-1.0-dev

## 2. MediaMTX (RTSP 서버) 설치
MediaMTX는 GStreamer가 영상을 '푸시(보내기)'하고, 지상제어스테이션(GCS)이 영상을 '풀(가져오기)'하는 허브 역할을 합니다.
다운로드: MediaMTX 릴리스 페이지로 이동하여 armv7 또는 arm64 버전을 다운로드하십시오.

    wget https://github.com/bluenviron/mediamtx/releases/download/v1.17.1/mediamtx_v1.17.1_linux_armv7.tar.gz

압축: 

    mkdir ~/mediamtx && cd ~/mediamtx
    tar -xvzf mediamtx_v1.6.0_linux_armv7.tar.gz

## 3. 비디오 파이프라인 스크립트
두 영상을 하나로 합치는 SBS(Side-by-Side) 병합 처리를 위한 스크립트를 생성합니다. 지상제어스테이션(GCS)에서 /video1 경로를 검색하므로 해당 경로를 사용합니다. 아래와 같이 셸 스크립트를 작성하십시오.

    nano ~/start_video_merge.sh

소스:

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
    

실행 가능하게 설정:

    chmod +x ~/start_video_merge.sh

## 4. 자동화 설정 (Systemd)
이 설정은 부팅 시 모든 프로세스가 자동으로 시작되도록 하며, 예기치 않은 오류로 프로세스가 중단될 경우 자동으로 재시작되도록 보장합니다.

A. MediaMTX Service

    sudo nano /etc/systemd/system/mediamtx.service

내용:

    Description=MediaMTX RTSP Server
    After=network-online.target
    [Service]
    User=pi
    WorkingDirectory=/home/pi/mediamtx
    ExecStart=/home/pi/mediamtx/mediamtx
    Restart=always
    [Install]
    WantedBy=multi-user.target

B. Video Merge Service

    sudo nano /etc/systemd/system/video-merge.service

소스:

    Description=GStreamer Merge Service
    After=mediamtx.service
    Requires=mediamtx.service
    [Service]
    User=pi
    ExecStart=/home/pi/start_video_merge.sh
    Restart=always
    RestartSec=5
    [Install]
    WantedBy=multi-user.target
    
## 4. 라즈베리 파이 네트워크 설정
이더넷 케이블(라우터)을 연결했을 때 라즈베리 파이의 Wi-Fi 연결이 끊기는 것을 방지하려면, 이더넷 포트에 고정 IP를 할당하고 네트워크 우선순위를 Wi-Fi보다 낮게 설정해야 합니다.

    sudo nano /etc/dhcpcd.conf

추가: 

    interface eth0
    static ip_address=192.168.144.25/24
    metric 1000

네트워크 재시작:

    sudo systemctl restart dhcpcd

## 5. 이더넷 자동 활성화 (Auto Wake-up)
라즈베리 파이는 부팅 시 연결이 감지되지 않으면 eth0 인터페이스를 비활성화하는 경우가 있습니다. 특히 라우터가 라즈베리 파이보다 늦게 부팅될 때 문제가 됩니다. 이를 해결하기 위해 이더넷 연결 상태를 지속적으로 스캔하고, 연결이 확인되면 즉시 인터페이스를 활성화하는 서비스를 생성해야 합니다.

    sudo nano /etc/systemd/system/eth-retry.service

내용:

    [Unit]
    Description=Retry Ethernet after boot
    After=network.target
    [Service]
    Type=oneshot
    ExecStart=/bin/sh -c "sleep 10 && ip link set eth0 down && ip link set eth0 up"
    [Install]
    WantedBy=multi-user.target

## 6. 최종 활성화

    sudo systemctl daemon-reload
    sudo systemctl enable eth-retry.service
    sudo systemctl enable mediamtx.service
    sudo systemctl enable video-merge.service
    sudo systemctl start mediamtx.service

## 문제 해결
서비스 상태 및 로그 확인:

    sudo systemctl status mediamtx.service
    sudo systemctl status video-merge.service

디버깅 시 서비스 중지 및 시작:

    sudo systemctl stop video-merge.service
    sudo systemctl start video-merge.service


# SIYI UniRC7 설정
작성 중...
