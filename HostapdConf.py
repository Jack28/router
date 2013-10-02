#!env python3

## STD
# interface=wlan0
# bridge=br0
# driver=nl80211
# ssid=MyNetwork
# hw_mode=g
#  a,b,g
# channel=1
#  1,2,3,4,5,6,7,8,9,10,11
# max_num_sta=5
# macaddr_acl=0
#  accept unless in deny

## NO SSID Broadcast
# ignore_broadcast_ssid=1

## ENCRYPTION
# auth_algs=1
#  1 open system auth 2 and shared key
# wpa=3
#  1 wpa 2 wpa2 3 both
# wpa_passphrase=tryyourbest
# wpa_key_mgmt=WPA-PSK
# wpa_pairwise=TKIP
# rsn_pairwise=CCMP

## sort of encryption
# wep_default_key=0
# wep_key0=moron

class HostapdConf:
	def __init__(self):
		self.std=dict()
		self.std['datei']='/tmp/quickHostapd.conf'
		self.std['interface']='wlan1'
		self.std['bridge']='br0'
		self.std['driver']='nl80211'
		self.std['ssid']='MyNetwork'
		self.std['hw_mode']='g'
		self.std['channel']='1'
		self.std['max_num_sta']='5'
		self.std['macaddr_acl']='0'
		self.std['ignore_broadcast_ssid']='0'

		self.crypt=dict()
		self.crypt['auth_algs']='1'
		self.crypt['wpa']='3'
		self.crypt['wpa_passphrase']='tryyourbest'
		self.crypt['wpa_key_mgmt']='WPA-PSK'
		self.crypt['wpa_pairwise']='TKIP'
		self.crypt['wpa_pairwise']='CCMP'

		self.wep=dict()
		self.wep['wep_default_key']='0'
		self.wep['wep_key0']='moron'

	def out(fd):
		for i in self.std:
			print("%c=%c"%(i,self.std[i]))

		fd.write()
