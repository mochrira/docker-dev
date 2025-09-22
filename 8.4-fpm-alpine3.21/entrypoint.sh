#!/bin/sh

NG_INSTALL="${NG_INSTALL:-NO}"
NG_VERSION="${NG_VERSION:-15.2}"

if [ $NG_INSTALL = YES ]; then
    if [ -z $(npm list -g | grep @angular/cli@${NG_VERSION}) ]
    then
        echo "Installing Angular version ${NG_VERSION}..."
        sudo npm install -g @angular/cli@${NG_VERSION}
        sudo npm cache clean --force
        sudo npm cache verify
    else
        echo "Angular version ${NG_VERSION} already installed"
    fi
fi

DIR="/workspace/www"
if [ ! -d "$DIR" ]; then
    mkdir -p /workspace/www
fi

if [ -f "/before_startup.sh" ]; then
  sh /before_startup.sh
fi

sudo /usr/bin/supervisord -n -c /etc/supervisord.conf