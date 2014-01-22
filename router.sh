#!/bin/bash
#set -x

# this script needs root rights
if [ "$(id -u)" != "0" ]; then
   echo "FATAL ERROR: This script must be run as root (sudo)!"
   exit 1
fi

routerroot=`pwd`

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
		ip, iw, iwconfig
		dnsmasq (DNS,DHCP)
		iptables (NAT,FW)
	additional requirements (hardware AP mode required):
		hostapd (AP)
		bridge-utils (AP)

	by felix f@ai4me.de
	version 0.1 02.10.2013
EOF
}

# print message green font
function message()
{
	echo -e "\e[1;32m$1\e[0m" # green
}

# print message red font
function error()
{
	echo -e "\e[1;31m$1\e[0m" # red
}

# check if software is installed and can be found
function check()
{
message "check"
for i in dnsmasq iptables hostapd brctl iwconfig
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

# start a given profile
function start()
{
(
message "start"
load_plugin $1
start_plugin $1
)
}

# stop a given profile
function stop()
{
(
message "stop"
load_plugin $1
stop_plugin $1
)
}

# TODO print out what's going on
function log()
{
message "log"
tail -f $1/dhcpleases &
journalctl -f $(which hostapd)
}

# list available profiles and echo description
function list()
{
find . -name "conf.sh" | while read i
do
	(
	dirname $i
	cd `dirname $i`
	source conf.sh
	echo "	"$comment
	)
done
}


function pre_post_run(){
	for plugin in "$@"
		do
		(
			load_plugin $plugin
			start_plugin $plugin
		)
		done
}

function pre_post_nur(){
	for plugin in "$@"
		do
		(
			load_plugin $plugin
			stop_plugin $plugin
		)
		done
}

function load_plugin(){
	if [ $# -lt 1 ]; then error "give profile"; exit 1; fi
	reset_plugin
	cd $routerroot/$1
	if [ $? -ne 0 ]; then error "profile not fount"; exit 1; fi
	source conf.sh
}
function reset_plugin(){
	cd $routerroot
	source init/conf.sh
}

function start_plugin(){
	pre_post_run $pre_run
	run
	pre_post_run $post_run
}

function stop_plugin(){
	pre_post_nur $pre_nur
	nur
	pre_post_nur $post_nur
}

# pass arguments to functions or/and print help on failure
$@
if [ $? -ne 0 ] || [ $# -lt 1 ]; then help; fi
