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
> python3 set_siyi_ip.py -t 변경전 IP 주소 -n 새로운 IP 주소

SIYI A2 Mini 카메라의 기본 IP 주소는 192.168.144.25 이므로, 다음과 같이 입력하여 IP 를 변경합니다.

* 1번 카메라 : 
> python3 set_siyi_ip.py -t 192.168.144.25 -n 192.168.144.23

* 2번 카메라 : 
> python3 set_siyi_ip.py -t 192.168.144.25 -n 192.168.144.24



## SIYI HDMI to IP Converter : IP 변경
상세 이미지가 있는 전체 매뉴얼은 [이 링크](<https://siyi.biz/siyi_file/Sky%20end%20card%20HDMI/Air%20Unit%20HDMI%20Converter%20User%20Manual_En%20v1.0.pdf>) 를 참고하세요.
MicroSD 카드에 setup.txt 파일을 생성합니다. 파일 내용은 아래와 같이 작성합니다.
>[NET_CONFIG]
>
>IP = 192.168.144.26

작성한 파일을 SD 카드에 저장하고 IP Converter 에 삽입합니다. 그리고 IP Converter 에 전원을 넣고 약 5분 정도 기다립니다.

IP 가 제대로 변경되었는지 확인하기 위해 SD 카드를 빼서 확인합니다. curip.txt 파일이 자동으로 생성되어 있으며, 해당 파일에 아래와 같이 변경된 IP 주소가 적혀있으면 정상적으로 변경된 것입니다.
>[NET_CONFIG]
>
>IP = 192.168.144.26



## 전체 배선
이제 아래의 배선도와 사진을 참고하여 모든 카메라와 RaspberryPi, IP Hub 를 연결합니다. 
![Map](https://github.com/falconshop/SIYI-3Camera-mode/blob/main/Map.jpg)
![Connect1](https://github.com/falconshop/SIYI-3Camera-mode/blob/main/Connect1.jpg)
![Connect2](https://github.com/falconshop/SIYI-3Camera-mode/blob/main/Connect2.jpg)



## RaspberryPi 작업
작성 중...


## SIYI UniRC7 설정
작성 중...
