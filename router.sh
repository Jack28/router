#!/bin/bash
set -x

function help()
{
cat << EOF
	Simple-Router-Script
		(simple as in quick and dirty)
	---------------------------
		$0 option [profile]

		options
			help		shows this page
			init		generates config files
			start <profile>	starts profile
			stop <profile>	stops profile
			list		lists profiles

	Profiles are kept in separate folders.
	Init generates profile init.

	requirements:
		ip, iw
		dnsmasq (DNS,DHCP)
		iptables (NAT,FW)
	additional requirements (hardware AP mode required):
		hostapd (AP)
		bridge-utils (AP)

	by felix f@ai4me.de
	version 0.1 02.10.2013
EOF
}

function message()
{
	echo -e "\e[1;32m$1\e[0m" # green
}

function error()
{
	echo -e "\e[1;31m$1\e[0m" # red
}

function init()
{
mkdir init
if [ $? -ne 0 ]; then error "init exists - no changes"; exit 1; fi
cd init

message "write conf.sh"
cat << EOF > conf.sh
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
	#iptables -A PREROUTING -t nat -i \$INTERFACE -p tcp --dst \$ROUTERIP --dport \$SRCPORT -j REDIRECT --to-port \$DESTPORT
	#iptables -A PREROUTING -t nat -i \$INTERFACE -p tcp --dport \$SRCPORT -j DNAT --to-destination 127.0.0.1:\$DESTPORT

###	iptables MASQUERADE

	nohup hostapd hostapd.conf > hostapd.log 2>&1 &
#	echo \$! > hostapd.pid

	dnsmasq -C dnsmasq.conf &
#	echo \$! > dnsmasq.pid

	#source adhoc.sh
}

# stop
function nur()
{
	#kill
#	ls *.pid | while read i; do
#		if [[ "\`ps -p \$(cat \$i)\`" =~ "\$(basename \$i .pid)" ]]; then
#			kill \$(cat \$i)
#			ps -p \$(cat \$i) > /dev/null
#			if [ \$? -eq 0 ]; then
#				kill -9 \$(cat \$i)
#			fi
#			rm \$i
#		fi
#	done

	killall hostapd
	killall dnsmasq

	sysctl -w net.ipv4.ip_forward=0

	ip l s br0 down
	ip l s wlp0s20u1 down
	ip a d 192.168.42.1/24 dev br0
	brctl delbr br0
	return 0
}
EOF

message "write dnsmasq.conf"
cat << EOF > dnsmasq.conf
interface=br0
except-interface=eth0
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

message "write hostapd.conf"
cat << EOF > hostapd.conf
interface=wlp0s20u1
bridge=br0
driver=nl80211
ssid=MyNetwork
# a,b,g,n
hw_mode=g
# 1,2,3,4,5,6,7,8,9,10,11,12,13
channel=4
max_num_sta=5
# accept unless in deny
macaddr_acl=0

# no ssid broadcast
#ignore_broadcast_ssid=1

# ENCRYPTION
# 1 open system auth 2 and shared key
auth_algs=1
# 1 wpa 2 wpa2 3 both
wpa=3
wpa_passphrase=almostRandom12345
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP

# sort of encryption
#wep_default_key=0
#wep_key0=moron
EOF

message "write adhoc.sh"
cat << EOF > adhoc.sh
ip l s wlan0 down
iwconfig wlan0 mode ad-hoc
iwconfig wlan0 channel 4
iwconfig wlan0 essid "MyNetwork"
iwconfig wlan0 key 2DB619D86F
ip l s wlan0 up
EOF
}

function check()
{
message "check"
for i in dnsmasq iptables hostapd brctl
do
	echo -n $i
	which $i > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		message " OK"
	else
		error " missing"
	fi
done
}

function start()
{
(
message "start"
if [ $# -lt 1 ]; then error "give profile"; exit 1; fi
cd ./$1
if [ $? -ne 0 ]; then error "profile not fount"; exit 1; fi
source conf.sh
run
)
}

function stop()
{
(
message "stop"
if [ $# -lt 1 ]; then error "give profile"; exit 1; fi
cd ./$1
if [ $? -ne 0 ]; then error "profile not fount"; exit 1; fi
source conf.sh
nur
)
}

function list()
{
find . -name "conf.sh" | while read i
do
	(
	dirname $i
	source $i
	echo "	"$comment
	)
done
}



$@
if [ $? -ne 0 ] || [ $# -lt 1 ]; then help; fi
