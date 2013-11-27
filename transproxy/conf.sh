#!/bin/bash
source config

comment="enable transparent proxy on $proxyif by redirecting $proxydports to $proxyport"

# start
function run()
{
	iptables -t nat -I PREROUTING 1 -i $proxyif -p tcp -m multiport --dports $proxydports -j REDIRECT --to-ports $proxyport
}

# stop
function nur()
{
	iptables -t nat -D PREROUTING -i $proxyif -p tcp -m multiport --dports $proxydports -j REDIRECT --to-ports $proxyport
}
