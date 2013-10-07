ip l s wlan0 down
iwconfig wlan0 mode ad-hoc
iwconfig wlan0 channel 4
iwconfig wlan0 essid "MyNetwork"
iwconfig wlan0 key 2DB619D86F
ip l s wlan0 up
