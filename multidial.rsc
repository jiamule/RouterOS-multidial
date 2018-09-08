# sep/09/2018 00:58:49 by RouterOS 6.42.6
# ROS四拨脚本，改掉5~8行的，interface值对应到自己的wan口、password值对应的宽带密码、user值宽带用户名

/interface pppoe-client
add add-default-route=yes comment="wan1pppoe" disabled=no interface=ether1 keepalive-timeout=60 max-mru=1480 max-mtu=1480 name=pppoe-out1 password=pppoepassword user=pppoeuser
add comment="wan2pppoe" interface=ether2 keepalive-timeout=60 max-mru=1480 max-mtu=1480 name=pppoe-out2 password=pppoepassword user=pppoeuser
add comment="wan3pppoe" interface=ether3 keepalive-timeout=60 max-mru=1480 max-mtu=1480 name=pppoe-out3 password=pppoepassword user=pppoeuser
add comment="wan4pppoe" interface=ether4 keepalive-timeout=60 max-mru=1480 max-mtu=1480 name=pppoe-out4 password=pppoepassword user=pppoeuser

/ip firewall address-list
add address=192.168.0.0/16 list=lanip

/ip firewall mangle
add action=change-mss chain=forward comment=mss new-mss=1440 protocol=tcp tcp-flags=syn
add action=mark-connection chain=input comment=in1 in-interface=pppoe-out1 new-connection-mark=con1
add action=mark-routing chain=output comment=out1 connection-mark=con1 new-routing-mark=1r
add action=mark-connection chain=input comment=in2 in-interface=pppoe-out2 new-connection-mark=con2
add action=mark-routing chain=output comment=out2 connection-mark=con2 new-routing-mark=2r
add action=mark-connection chain=input comment=in3 in-interface=pppoe-out3 new-connection-mark=con3
add action=mark-routing chain=output comment=out3 connection-mark=5qqcon3 new-routing-mark=3r
add action=mark-connection chain=input comment=in4 in-interface=pppoe-out4 new-connection-mark=con4
add action=mark-routing chain=output comment=out4 connection-mark=5qqcon4 new-routing-mark=4r
add action=mark-connection chain=prerouting comment=pcc1 dst-address-type=!local new-connection-mark=1 per-connection-classifier=both-addresses:4/0 src-address-list=lanip
add action=mark-routing chain=prerouting comment=pcc1 connection-mark=1 new-routing-mark=1r src-address-list=lanip
add action=mark-connection chain=prerouting comment=pcc2 dst-address-type=!local new-connection-mark=2 per-connection-classifier=both-addresses:4/1 src-address-list=lanip
add action=mark-routing chain=prerouting comment=pcc2 connection-mark=2 new-routing-mark=2r src-address-list=lanip
add action=mark-connection chain=prerouting comment=pcc3 dst-address-type=!local new-connection-mark=3 per-connection-classifier=both-addresses:4/2 src-address-list=lanip
add action=mark-routing chain=prerouting comment=pcc3 connection-mark=3 new-routing-mark=3r src-address-list=lanip
add action=mark-connection chain=prerouting comment=pcc4 dst-address-type=!local new-connection-mark=4 per-connection-classifier=both-addresses:4/3 src-address-list=lanip
add action=mark-routing chain=prerouting comment=pcc4 connection-mark=4 new-routing-mark=4r src-address-list=lanip
/ip firewall nat
add action=masquerade chain=srcnat out-interface=pppoe-out1
add action=masquerade chain=srcnat out-interface=pppoe-out2
add action=masquerade chain=srcnat out-interface=pppoe-out3
add action=masquerade chain=srcnat out-interface=pppoe-out4

/ip route
add distance=1 gateway=pppoe-out1 routing-mark=1r
add distance=1 gateway=pppoe-out2 routing-mark=2r
add distance=1 gateway=pppoe-out3 routing-mark=3r
add distance=1 gateway=pppoe-out4 routing-mark=4r
