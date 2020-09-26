#!/bin/sh

SOFT_DIR=./openresty-1.17.8
INSTALL=/tmp/openresty
DISTRIBUTION=


if [ ! -d $INSTALL ];then
    echo "[info] create dep package dir ..."
    mkdir $INSTALL -p
fi

# 编译
build_soft(){
  cd $SOFT_DIR
  # configure ...
  make
}

copy_cofig(){
  make install DESTDIR=$INSTALL
  mkdir -p $INSTALL/var/lib/nginx/body
  install -m 0555 -D ../files/nginx.init $INSTALL/etc/init.d/nginx
  install -m 0555 -D ../files/nginx.conf $INSTALL/etc/nginx/nginx.conf
  install -m 0555 -D ../files/mime.types $INSTALL/etc/nginx/mime.types
  install -m 0555 -D ../files/nginx.logrotate $INSTALL/etc/logrotate.d/nginx
}

build_deb(){
  fpm -s dir -t deb -n nginx -v 1.17.8.2 --iteration 1 -C /data/openresty-v3 -p /tmp \
  -d 'libxml2-dev,libxslt1-dev,libgd-dev,libgeoip-dev,libpcre3-dev' \
  --description "openresty 1.17.8.2" \
  --config-files /etc/nginx/fastcgi.conf.default \
  --config-files /etc/nginx/win-utf \
  --config-files /etc/nginx/fastcgi_params \
  --config-files /etc/nginx/nginx.conf \
  --config-files /etc/nginx/koi-win \
  --config-files /etc/nginx/nginx.conf.default \
  --config-files /etc/nginx/mime.types.default \
  --config-files /etc/nginx/koi-utf \
  --config-files /etc/nginx/uwsgi_params \
  --config-files /etc/nginx/uwsgi_params.default \
  --config-files /etc/nginx/fastcgi_params.default \
  --config-files /etc/nginx/mime.types \
  --config-files /etc/nginx/scgi_params.default \
  --config-files /etc/nginx/scgi_params \
  --config-files /etc/nginx/fastcgi.conf \
  etc usr var
}


# 打包
