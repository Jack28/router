#!/bin/bash

# comment
comment="Some useful information about the profile."

# start
function run()
{
	brctl addbr br0
	ip a a 192.168.42.1/24 dev br0
	ip l s br0 up

	systemctl start iptables
	sysctl -w net.ipv4.ip_forward=1
	# transparent proxy
	#iptables -A PREROUTING -t nat -i $INTERFACE -p tcp --dst $ROUTERIP --dport $SRCPORT -j REDIRECT --to-port $DESTPORT
	#iptables -A PREROUTING -t nat -i $INTERFACE -p tcp --dport $SRCPORT -j DNAT --to-destination 127.0.0.1:$DESTPORT

	# NAT
	iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

	hostapd -B -P hostapd.pid hostapd.conf
#	echo $! > hostapd.pid

	dnsmasq --pid-file=dnsmasq.pid -C dnsmasq.conf
#	echo $! > dnsmasq.pid

	#source adhoc.sh
}

# stop
function nur()
{
	#kill
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

	killall dnsmasq

	sysctl -w net.ipv4.ip_forward=0

	# NAT
	iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

	ip l s br0 down
	ip l s wlp0s20u1 down
	ip a d 192.168.42.1/24 dev br0
	brctl delbr br0
	return 0
}
