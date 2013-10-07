#!/bin/bash
#set -x

if [ "$(id -u)" != "0" ]; then
   echo "FATAL ERROR: This script must be run as root (sudo)!"
   exit 1
fi

function help()
{
cat << EOF
	Simple-Router-Script
		(simple as in quick and dirty)
	---------------------------
		$0 option [profile]

		options
			help		shows this page
			start <profile>	starts profile
			stop <profile>	stops profile
			log <profile>	follow logging
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

function log()
{
message "log"
tail -f $1/dhcpleases &
journalctl -f $(which hostapd)
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
