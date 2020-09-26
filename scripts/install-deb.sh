#!/bin/sh

apt update -y && \
apt libxml2-dev libxslt1-dev libgd-dev libgeoip-dev libpcre3-dev -y

dpkg -i ../deb-package/nginx_1.17.8.2-1_amd64.deb

