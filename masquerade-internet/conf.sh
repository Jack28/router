#!/bin/bash

# Some usful information about the profile.
comment=""

source config

function run()
{
	sysctl -w net.ipv4.ip_forward=1
	iptables -t nat -A POSTROUTING -o $internet_interface -j MASQUERADE
}

# stop
function nur()
{
	sysctl -w net.ipv4.ip_forward=0
	iptables -t nat -D POSTROUTING -o $internet_interface -j MASQUERADE
}
