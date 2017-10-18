FROM dimovnike/alpine-supervisord
MAINTAINER nikolay dimov

RUN apk add --update openvpn && rm  -rf /tmp/* /var/cache/apk/*

ADD supervisord-openvpn.conf /etc/supervisor/conf.d/
ADD openvpn-up.sh run-openvpn.sh /usr/local/bin/

