#!/bin/bash

# Some usful information about the profile.
source config 

comment="add new monitor interface mon0 from $monitor_interface"

pre_run=""
post_run=""

pre_nur=""
post_nur=""

function run()
{
	ip link set dev $monitor_interface down
	iw dev $monitor_interface interface add mon0 type monitor flags none	
	ip link set dev mon0 up
}

function nur()
{
	iw dev mon0 del
	ip link set dev $monitor_interface down
}

