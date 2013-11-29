#!/bin/bash
source config

comment="Start an access point on $wlanif with gateway via $gatewayif (hostapd). Password: 5thNovember, WPA2"

post_run="masquerade-internet"
pre_nur="masquerade-internet"

# start
function run()
{
	ip addr add 192.168.42.1/24 dev $wlanif 

write_dnsmasqconf
	dnsmasq --pid-file=/var/run/router_dnsmasq.pid -C dnsmasq.conf

	write_hostapdconf
	hostapd -B -P /var/run/router_hostapd.pid hostapd.conf
}

function post_run(){
	echo "internet"
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
EOF

if [[ $mode = "opn" ]]
	then
cat >> hostapd.conf << EOF
auth_algs=1
EOF
		return
	fi

if [[ $mode = "wep" ]]
then
cat >> hostapd.conf << EOF
auth_algs=$auth_algs
wep_default_key=0
wep_key0="$wep_key"
EOF

else

cat >> hostapd.conf << EOF
wpa=$wpa
wpa_passphrase=$wpa_passphrase
rsn_pairwise=CCMP
EOF

fi
}
