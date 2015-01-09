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

mkdir -p $WWW/{html,cgi,logs,tmp}
chown $USER:$USER $WWW -R
#chmod u=rwx $WWW -R
chmod 600 $WWW/html -R; chmod u+X $WWW/html -R

cat << EOF > $HTTPD/$USER.conf
<VirtualHost *:80>
	ServerName $HOST
	ServerAlias www.$HOST
	DocumentRoot $WWW/html
	ErrorLog $WWW/logs/error.log
	CustomLog $WWW/logs/access.log combined
	AssignUserID $USER $USER
	php_admin_value sys_temp_dir $WWW/tmp
    	php_admin_value session.save_path $WWW/tmp
    <Directory $WWW/html>
        Require all granted
		AllowOverride  All
		allow from all
		Options +Indexes
	</Directory>
</VirtualHost>
EOF
service httpd reload
