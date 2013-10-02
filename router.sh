#!/bin/bash

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
		dnsmasq (DNS,DHCP)
		iptables (NAT,FW)
	additional requirements:
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
# start
function run()
{
echo run
}

# stop
function nur()
{
echo nur
}

# comment
comment="Some useful information about the profile."
EOF

message "write dnsmasq.conf"
cat << EOF > dnsmasq.conf
interface=wlan0
except-interface=eth0
domain=test
dhcp-range=192.168.42.100,192.168.42.150,5m
dhcp-option=3,192.168.42.1
dhcp-option=6,192.168.42.1
dhcp-leasefile=dhcpleases
EOF
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
if [ $? -ne 0 ]; then help; fi
