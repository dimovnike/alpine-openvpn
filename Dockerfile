FROM dimovnike/alpine-supervisord

RUN apk add --update iptables openvpn && rm  -rf /tmp/* /var/cache/apk/*

ADD supervisord-openvpn.conf /etc/supervisor/conf.d/
ADD openvpn-up.sh run-openvpn.sh /usr/local/bin/

