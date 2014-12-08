#!/bin/sh
[ -z $1 ] && (echo "Enter USERname"; exit 1)
HOST=$1
USER=${HOST//./-}

HTML="/home/$USER/www/html"

chown $USER:$USER $HTML
chmod -R u=rw,go=r $HTML
chmod -R a+X $HTML