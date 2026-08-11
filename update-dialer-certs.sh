#!/bin/bash

/usr/bin/certbot renew
/usr/sbin/asterisk -rx "module reload http"

if [ -f /etc/almalinux-release ]; then
    /usr/bin/systemctl reload httpd
else
    /usr/bin/systemctl reload apache2
fi
