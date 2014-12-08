#!/bin/sh
[ -z $1 ] && (echo "Enter USERname"; exit 1)
HOST=$1
USER=${HOST//./-}
HTTPD=/etc/httpd/conf.d
BASE=/home
WWW="$BASE/$USER/www"
useradd -s /sbin/nologin $USER
passwd $USER
chown apache:$USER $BASE/$USER
chmod ug=rx,g+w,o-rw $BASE/$USER

mkdir -p $WWW
chown apache:apache $WWW
chmod a=rx $WWW

mkdir -p $WWW/html
mkdir -p $WWW/cgi
chown $USER:$USER $WWW/html $WWW/cgi
chmod u=rwx,go=rx $WWW/html $WWW/cgi

mkdir -p $WWW/logs
chown apache:apache $WWW/logs
chmod u=rwx,go=rx $WWW/logs

mkdir -p $WWW/tmp
chown apache:apache $WWW/tmp
chmod a=rwx $WWW/tmp

cat << EOF > $HTTPD/$USER.conf
<VirtualHost *:80>
	ServerName $HOST
	ServerAlias www.$HOST
	DocumentRoot $WWW/html
	ErrorLog $WWW/logs/error.log
	CustomLog $WWW/logs/access.log combined
    <Directory $WWW/html>
        Require all granted
		AllowOverride  All
		allow from all
		Options +Indexes
	</Directory>
</VirtualHost>
EOF
service httpd reload