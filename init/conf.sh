#!/bin/bash

# comment
comment="Some useful information about the profile."

# start
function run()
{
	# add network bridge
	# used by hostapd
	brctl addbr br0
	# set router ip address
	ip a a 192.168.42.1/24 dev br0
	ip l s br0 up

	# start iptables
	systemctl start iptables
	# enable forwarding
	sysctl -w net.ipv4.ip_forward=1

	# transparent proxy for MITM research
	#iptables -A PREROUTING -t nat -i $INTERFACE -p tcp --dst $ROUTERIP --dport $SRCPORT -j REDIRECT --to-port $DESTPORT
	#iptables -A PREROUTING -t nat -i $INTERFACE -p tcp --dport $SRCPORT -j DNAT --to-destination 127.0.0.1:$DESTPORT

	# NAT
	iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

	# start hostapd to open up "real" wireless lan
	# requires AP mode supported by hardware
	hostapd -B -P hostapd.pid hostapd.conf
#	echo $! > hostapd.pid

	# start dnsmasq to handle dhcp and dns requests
	dnsmasq --pid-file=dnsmasq.pid -C dnsmasq.conf
#	echo $! > dnsmasq.pid

	#source adhoc.sh
}

# stop
function nur()
{
	# kill
	# killall PID's for which a *.pid file is in profile directory
	ls *.pid | while read i; do
		if [[ "`ps -p $(cat $i)`" =~ "$(basename $i .pid)" ]]; then
			kill $(cat $i)
			ps -p $(cat $i) > /dev/null
			if [ $? -eq 0 ]; then
				kill -9 $(cat $i)
			fi
			rm $i
		fi
	done

	# kill all dnsmasq
	killall dnsmasq

	# disable forwarding
	sysctl -w net.ipv4.ip_forward=0

	# disable NAT
	iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

	# set down interfaces
	ip l s br0 down
	ip l s wlp0s20u1 down
	ip a d 192.168.42.1/24 dev br0
	brctl delbr br0
	return 0
}
