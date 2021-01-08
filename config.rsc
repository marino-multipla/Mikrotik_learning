# oct/02/2020 16:12:54 by RouterOS 6.45.X
# software id = XXXXXXXXXXXXXXXX
#
# model = RB941-2nD
# serial number = XXXXXXXXXXXXXXXX
/interface wireless
# managed by CAPsMAN
set [ find default-name=wlan1 ] ssid=MikroTik
/interface ethernet
set [ find default-name=ether1 ] name=ether1_TIM
set [ find default-name=ether2 ] name=ether2_P8
set [ find default-name=ether3 ] name=ether3_TEST
set [ find default-name=ether4 ] name=ether4_LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/interface bridge port
add comment=defconf interface=ether1_TIM
add comment=defconf interface=ether2_P8
add comment=defconf interface=ether3_TEST
add comment=defconf interface=ether4_LAN
/interface wireless cap
# 
set discovery-interfaces=*7 enabled=yes interfaces=wlan1
/ip address
add address=192.168.0.90/24 interface=ether3_TEST network=192.168.0.0
add address=192.168.1.3/24 interface=ether1_TIM network=192.168.1.0
add address=192.168.3.2/24 interface=ether2_P8 network=192.168.3.0
add address=192.168.4.1/24 interface=ether4_LAN network=192.168.4.0
/ip dhcp-client
add comment=defconf dhcp-options=hostname,clientid disabled=no
/ip firewall address-list
add address=192.168.1.0/24 list=Connected
add address=192.168.3.0/24 list=Connected
add address=192.168.4.0/24 list=Connected
add address=192.168.4.0/24 list=LAN
/ip firewall mangle
add action=accept chain=prerouting dst-address-list=Connected \
    src-address-list=Connected
add action=mark-connection chain=input connection-mark=no-mark in-interface=\
    ether1_TIM new-connection-mark=TIM-ROS passthrough=no
add action=mark-connection chain=input connection-mark=no-mark in-interface=\
    ether2_P8 new-connection-mark=P8-ROS passthrough=no
add action=mark-routing chain=output connection-mark=TIM-ROS \
    new-routing-mark=TIM_Route passthrough=no
add action=mark-routing chain=output connection-mark=P8-ROS new-routing-mark=\
    P8_Route passthrough=no
add action=mark-connection chain=forward connection-mark=no-mark \
    in-interface=ether1_TIM new-connection-mark=TIM-LAN passthrough=no
add action=mark-connection chain=forward connection-mark=no-mark \
    in-interface=ether2_P8 new-connection-mark=P8-LAN passthrough=no
add action=mark-routing chain=prerouting connection-mark=TIM-LAN \
    new-routing-mark=TIM_Route passthrough=no src-address-list=LAN
add action=mark-routing chain=prerouting connection-mark=P8-LAN \
    new-routing-mark=P8_Route passthrough=no src-address-list=LAN
add action=mark-connection chain=prerouting connection-mark=no-mark \
    dst-address-list=!Connected dst-address-type=!local new-connection-mark=\
    LAN-WAN passthrough=no src-address-list=LAN
add action=mark-routing chain=prerouting comment="Load Balancing Here" \
    connection-mark=LAN-WAN new-routing-mark=TIM_Route passthrough=no \
    src-address-list=LAN
add action=mark-connection chain=prerouting connection-mark=LAN-WAN \
    new-connection-mark=Sticky_TIM passthrough=no routing-mark=TIM_Route
add action=mark-connection chain=prerouting connection-mark=LAN-WAN \
    new-connection-mark=Sticky_P8 passthrough=no routing-mark=P8_Route
add action=mark-routing chain=prerouting connection-mark=Sticky_TIM \
    new-routing-mark=TIM_Route passthrough=no src-address-list=LAN
add action=mark-routing chain=prerouting connection-mark=Sticky_P8 \
    new-routing-mark=P8_Route passthrough=no src-address-list=LAN
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1_TIM
add action=masquerade chain=srcnat out-interface=ether2_P8
add action=dst-nat chain=dstnat dst-address=192.168.1.3 dst-port=4096 \
    protocol=tcp to-addresses=192.168.4.45 to-ports=4096
add action=dst-nat chain=dstnat dst-address=192.168.3.2 dst-port=4096 \
    protocol=tcp to-addresses=192.168.4.45 to-ports=4096
/ip route
add check-gateway=ping distance=1 gateway=192.168.1.1 routing-mark=TIM_Route
add check-gateway=ping distance=1 gateway=192.168.3.1 routing-mark=P8_Route
add check-gateway=ping distance=1 gateway=192.168.1.1
add check-gateway=ping distance=2 gateway=192.168.3.1
/system clock
set time-zone-name=Europe/Rome
