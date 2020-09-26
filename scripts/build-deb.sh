#!/bin/bash

source ./config.sh
SOFT_DIR=../openresty-1.17.8
SOFT_NAME=nginx
SOFT_VERSION=1.17.8.2
INSTALL=/tmp/openresty
LINUX=$(python -c "import platform;dist=platform.dist();print dist[0].lower(), dist[1], dist[2]")
LINUX_VERSION="$(echo $LINUX | cut -d' ' -f1)"

# 基础包安装
pre_dep(){
  apt update -y && \
  apt install libxml2-dev libxslt1-dev libgd-dev libgeoip-dev libpcre3-dev -y
}

usage(){
    echo "=============== Command panel ==============="
    echo '(1) apt update of build depend'
    echo '(2) openresty,source compile only'
    echo '(3) openresty,install app to prd'
    echo '(4) openresty,fpm build deb package'
    echo "============================================= "
}

check_os(){
  case $LINUX_VERSION in
    ubuntu|debian)
        TARGET="deb"
        ;;
    centos|redhat)
        TARGET="rpm"
        ;;
    *)
        echo "[info] not support os."
        exit 1
  esac

  echo "[info] os description $LINUX_VERSION "

  if [ ! -d $INSTALL ];then
      echo "[info] create dep package dir $INSTALL"
      mkdir $INSTALL -p
  fi
}

# 编译
build_app(){
  cd $SOFT_DIR
  $CONFIG_PARM
  make
}

# 安装到生产环境
install_prd(){
  make install
}

# 安装到打包目录
install_app(){
  make install DESTDIR=$INSTALL
  mkdir -p $INSTALL/var/lib/nginx/body
  install -m 0555 -D ../files/nginx.init $INSTALL/etc/init.d/nginx
  install -m 0555 -D ../files/nginx.conf $INSTALL/etc/nginx/nginx.conf
  install -m 0555 -D ../files/mime.types $INSTALL/etc/nginx/mime.types
  install -m 0555 -D ../files/nginx.logrotate $INSTALL/etc/logrotate.d/nginx
}

build_package(){
  fpm -s dir -t $TARGET -n $SOFT_NAME -v $SOFT_VERSION --iteration 1 -C $INSTALL -p /tmp \
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

  echo "[info] build task done, see /tmp catalogue"
}


main(){
  usage
  check_os
#  build_app
#  install_prd
#  install_app
  read -p "Please input number:" -t 30 num
  case $num in
    1)
      # build 依赖包
      pre_dep
      ;;
    2)
      # step configure & make only
      build_app
      ;;
    3)
      # 安装到生产环境
      build_app
      install_prd
      ;;
    4)
      # fpm打包
      build_app
      install_app
      build_package
      ;;
    *)
      exit 1
      ;;
  esac
}

main
