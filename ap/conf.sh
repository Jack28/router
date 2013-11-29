#!/bin/bash
source config

comment="Start an access point on $wlanif with gateway via $gatewayif (hostapd). Password: 5thNovember, WPA2"

# start
function run()
{
	sysctl -w net.ipv4.ip_forward=1

	iptables -t nat -A POSTROUTING -o $gatewayif -j MASQUERADE

	ip addr add 192.168.42.1/24 dev $wlanif 

write_dnsmasqconf
	dnsmasq --pid-file=/var/run/router_dnsmasq.pid -C dnsmasq.conf

	write_hostapdconf
	hostapd -B -P /var/run/router_hostapd.pid hostapd.conf
}

# stop
function nur()
{
	#kill
	ls /var/run/router_*.pid| while read i; do
		kill $(cat $i)
		ps -p $(cat $i) > /dev/null
		if [ $? -eq 0 ]; then
			kill -9 $(cat $i)
		fi
		rm $i
	done

	sysctl -w net.ipv4.ip_forward=0

	# NAT
	iptables -t nat -D POSTROUTING -o $gatewayif -j MASQUERADE

	ip a d 192.168.42.1/24 dev $wlanif 
	ip link set dev $wlanif down	
	return 0
}


function write_dnsmasqconf(){
cat >dnsmasq.conf << EOF
interface=$wlanif
except-interface=$gatewayif
domain=test
# start, end, leasetime
dhcp-range=192.168.42.100,192.168.42.150,5m
# gateway
dhcp-option=3,192.168.42.1
# dns
dhcp-option=6,192.168.42.1
dhcp-leasefile=dhcpleases
# dns-hosts
address=/fritz.box/192.168.42.1
EOF
}

function write_hostapdconf(){
cat > hostapd.conf << EOF
interface=$wlanif
driver=nl80211
ssid=$ssid
channel=1
wpa=$wpa
wpa_passphrase=$wpa_passphrase
rsn_pairwise=CCMP

EOF
}
