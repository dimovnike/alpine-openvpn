# Openvpn in a container.
Openvpn is set up in a way that no direct connection is allowed from the container (we modify routes and set iptables). 

### Purpose

The purpose of this container is to be extended with layers that need access only via VPN.

### Configuration

Openvpn will search for config file in /etc/openvpn\_host/, it will cd into this directory and will try to load a file named openvpnconfig.conf. To provide this file, an external volume must be mapped with:

```-v \</path/to/openvpn-configs\>:/etc/openvpn\_host/```

The final run command can be:

```docker run -v </path/to/openvpn-configs>:/etc/openvpn_host/ --privileged -d dimovnike/alpine-openvpn```

### Limitations

* needs --privileged
* supports only tun devices
