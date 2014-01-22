#!/bin/bash

# Some usful information about the profile.
source config 

comment=""

pre_run=""
post_run=""

pre_nur=""
post_nur=""

function run()
{
	ip link set promisc on dev $promisc_interface	
}

function nur()
{
	ip link set promisc off dev $promisc_interface	
}

