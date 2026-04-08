# 카메라가 연결되었는지 확인하려면: ping -c 4 192.168.144.25
#
# python3 set_siyi_ip.py --help
# 사용법: python3 set_siyi_ip.py -t 192.168.144.25 -n 192.168.144.24
# -t 	 - 대상(현재) IP
# -n 	 - 새로운 IP
# --help - 도움말 표시
#
#
# 이 스크립트는 SIYI A2 MINI 카메라에서 테스트되었습니다.
# https://www.falconshop.co.kr

import socket
import argparse
import sys

def ip_to_little_endian_bytes(ip_string):
    """표준 IP를 리틀 엔디안(Little Endian) 바이트 배열로 변환합니다."""
    try:
        parts = [int(p) for p in ip_string.split('.')]
        if len(parts) != 4 or any(p < 0 or p > 255 for p in parts):
            raise ValueError
        # 리틀 엔디안 형식을 위해 순서를 뒤집습니다.
        return bytes(parts[::-1])
    except ValueError:
        print(f"오류: 잘못된 IP 주소 형식입니다 -> '{ip_string}'")
        sys.exit(1)

def get_gateway_bytes(ip_string):
    """주어진 서브넷의 게이트웨이를 .1로 가정하고 리틀 엔디안 바이트를 반환합니다."""
    parts = [int(p) for p in ip_string.split('.')]
    parts[3] = 1 # 마지막 옥텟을 1로 강제 설정합니다 (예: 192.168.144.1)
    return bytes(parts[::-1])

def calc_siyi_crc16(data: bytes) -> int:
    crc = 0
    for byte in data:
        crc ^= (byte << 8)
        for _ in range(8):
            if crc & 0x8000:
                crc = ((crc << 1) ^ 0x1021) & 0xFFFF
            else:
                crc = (crc << 1) & 0xFFFF
    return crc

def main():
    # 명령줄 인수 구문 분석 설정
    parser = argparse.ArgumentParser(description="SIYI 카메라 IP 설정 도구")
    parser.add_argument("-t", "--target", required=True, help="카메라의 현재 IP (예: 192.168.144.25)")
    parser.add_argument("-n", "--new", required=True, help="카메라에 설정할 새로운 IP (예: 192.168.144.24)")
    args = parser.parse_args()

    target_ip = args.target
    new_ip = args.new
    target_port = 37260

    print(f"\n--- SIYI IP 설정 도구 ---")
    print(f"대상 카메라 : {target_ip}:{target_port}")
    print(f"새로운 IP 주소: {new_ip}")

    # 1. 페이로드(Payload) 조립
    header = bytes.fromhex("55 66 01 0C 00 00 00 82")
    new_ip_bytes = ip_to_little_endian_bytes(new_ip)
    subnet_bytes = bytes.fromhex("00 FF FF FF") # 리틀 엔디안 형식의 255.255.255.0
    gateway_bytes = get_gateway_bytes(new_ip)
    
    payload_no_crc = header + new_ip_bytes + subnet_bytes + gateway_bytes

    # 2. CRC 계산
    new_crc = calc_siyi_crc16(payload_no_crc)
    
    # 3. CRC 추가 (리틀 엔디안 형식)
    low_byte = new_crc & 0xFF
    high_byte = (new_crc >> 8) & 0xFF
    final_packet = payload_no_crc + bytes([low_byte, high_byte])
    
    formatted_payload = " ".join(f"{b:02X}" for b in final_packet)
    print(f"생성된 페이로드: {formatted_payload}")

    # 4. UDP를 통해 전송
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(3.0)
    
    print("패킷 전송 중...")
    sock.sendto(final_packet, (target_ip, target_port))

    # 5. 응답(Ack) 대기 및 검증
    try:
        data, addr = sock.recvfrom(1024)
        response_hex = " ".join(f"{b:02X}" for b in data).upper()
        
        # 고정된 성공 응답 문자열
        EXPECTED_ACK = "55 66 02 01 00 01 00 82 01 B4 48"
        
        if response_hex == EXPECTED_ACK:
            print(f"\n완벽합니다! 카메라 IP가 성공적으로 변경되었습니다.")
            print(f"응답 코드: {response_hex}")
            print(f"카메라의 전원을 껐다 켜고, 약 60초 후에 {new_ip}로 핑(ping)을 테스트하세요.")
        else:
            print(f"\n알 수 없는 응답을 받았습니다: {response_hex}")
            print(f"예상된 성공 응답({EXPECTED_ACK})과 다릅니다. 설정이 적용되지 않았을 수 있습니다.")
    except socket.timeout:
        print("\n명령이 전송되었지만, 응답을 받지 못했습니다.")
        print(f"일단 카메라의 전원을 껐다 켜고 {new_ip}로 핑(ping) 테스트를 시도해 보세요.")
    finally:
        sock.close()

if __name__ == "__main__":
    main()