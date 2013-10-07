function addhoc()
{
	ip l s wlan0 down
	iwconfig wlan0 mode ad-hoc
	iwconfig wlan0 channel 4
	iwconfig wlan0 essid "MyNetwork"
	iwconfig wlan0 key "2DB619D86F"
#	iwconfig wlan0 key s:moron
	ip l s wlan0 up
}

function subhoc()
{
	ip l s wlan0 down
	iwconfig wlan0 mode managed
}
