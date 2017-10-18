#!/bin/sh

set -e

# prepare vpn
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
	mknod /dev/net/tun c 10 200
fi

OVPNCONF=/etc/openvpn_host/openvpnconfig.conf

[ -f $OVPNCONF ] || {
	echo /etc/openvpn_host/openvpnconfig.conf is missing please provide the volume with the file  > /dev/stderr; 
	exit 1; 
}

REMOTE=`grep '^remote\s' $OVPNCONF | awk '{print $2}'`
DEFAULTGW=`ip ro ls | grep default | awk '{print $3}'`

[ -n "$REMOTE" ] || { 
	echo no remote in /etc/openvpn_host/openvpnconfig.conf > /dev/stderr; 
	exit 1; 
}
[ -n "$DEFAULTGW" ] || { 
	echo could not determine default gateway > /dev/stderr; 
	exit 1; 
}


# flush and set policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP

# set lo
iptables -A INPUT  -i lo
iptables -A OUTPUT -o lo

# allow returning packets for all interfaces
iptables -A INPUT -p tcp  -m state --state RELATED,ESTABLISHED -j ACCEPT 
iptables -A INPUT -p udp  -m state --state RELATED,ESTABLISHED -j ACCEPT 
iptables -A INPUT -p icmp -m state --state RELATED,ESTABLISHED -j ACCEPT 

# vpn server
iptables -A OUTPUT -o eth0 -d $REMOTE -j ACCEPT

# allow output on tun0
iptables -A OUTPUT -o tun0 -j ACCEPT

ip ro add $REMOTE via $DEFAULTGW dev eth0

/usr/sbin/openvpn --script-security 2 --up /usr/local/bin/openvpn-up.sh \
	--status /etc/openvpn_host/openvpnconfig.status 10 --redirect-gateway local \
	--cd /etc/openvpn_host --config $OVPNCONF

# take the whole container with us
echo openvpn died
kill 1 # kill the supervisor so the container dies
