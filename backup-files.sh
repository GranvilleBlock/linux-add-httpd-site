#!/bin/sh
# Directory backup with rotation
#
# p0vidl0 © 2015
#
# Parameters:
#   1. Rotation type: required, must be in "daily|weekly|monthly".
#   2. Backup type: required, must be in "local|remote". "remote" will mount and umount backup path.
#   3. Backup path: non-required. Must be without trailing slash "/".
#   4. Date and time stamp format: non-required. Example "%Y-%m-%d-%H-%M-%S".
#
# crontab examlpe
# 55 2 * * * rm /var/cache/davfs2/webdav.yandex.ru+mnt-backup.yd+root/*
# 0 3 2-31 * 1-6 /root/tools/backup-mysql.sh daily remote /mnt/backup.yd >> /var/log/backup/mysql.log
# 0 4 2-31 * 1-6 /root/tools/backup-files.sh daily remote /mnt/backup.yd >> /var/log/backup/files.log
# 20 3 * * 0 [ "$(date +\%d)" -ne "01" ] && /root/tools/backup-mysql.sh weekly remote /mnt/backup.yd >> /var/log/backup/mysql.log
# 20 4 * * 7 [ "$(date +\%d)" -ne "01" ] && /root/tools/backup-files.sh weekly remote /mnt/backup.yd >> /var/log/backup/files.log
# 40 3 1 * * /root/tools/backup-mysql.sh monthly remote /mnt/backup.yd >> /var/log/backup/mysql.log
# 40 4 1 * * /root/tools/backup-files.sh monthly remote /mnt/backup.yd >> /var/log/backup/files.log

#####################################################################################################

echo "[--------------------------------[`date +%F--%H-%M`]--------------------------------]" 
echo "[----------][`date +%F--%H-%M`] Run the backup script..."

TIMESTAMP="%Y-%m-%d-%H-%M-%S"
BACKUP_PATH="/mnt/backup.yd"
HTTPD_CONF_PATH="/etc/httpd"

#Parameters check
ROTATION=$1
case $ROTATION in
"daily")
ROTATION_DAYS=7
;;
"weekly")
ROTATION_DAYS=29
;;
"monthly")
ROTATION_DAYS=0
;;
*)
echo "[----------][`date +%F--%H-%M`] Need first parameter: Rotation type. Must be in \"daily|weekly|monthly\". Exit."
exit 1
esac

echo "[----------][`date +%F--%H-%M`] First parameter: rotation is $ROTATION and days is $ROTATION_DAYS"

if [[ -z $2 ]]
then 
echo "[----------][`date +%F--%H-%M`] Need second parameter: Backup type. Must be in \"local|remote\". Exit."
exit 1
fi
echo "[----------][`date +%F--%H-%M`] Second parameter: backup type is $2."

if [[ -n $3 ]]
then 
#$BACKUP_PATH=$3
echo "[----------][`date +%F--%H-%M`] Third parameter: backup path is $BACKUP_PATH"
else
echo "[----------][`date +%F--%H-%M`] Third parameter: timestamp is missing."
fi

if [[ -n $4 ]]
then 
$TIMESTAMP=$4
echo "[----------][`date +%F--%H-%M`] Fourth parameter: timestamp is $TIMESTAMP"
else
echo "[----------][`date +%F--%H-%M`] Fourth parameter: timestamp is missing"
fi

# Calculate variables
HOST=`hostname`
echo "[----------][`date +%F--%H-%M`] Hostname: $HOST"
FILE_PATH="$BACKUP_PATH/$HOST/home/$ROTATION"
echo "[----------][`date +%F--%H-%M`] Backup files path: $FILE_PATH"

# Mount remote path
if [[ "$2" = "remote" ]]
then
mount $BACKUP_PATH
echo "[----------][`date +%F--%H-%M`] Backup path is mounted"
else
echo "[----------][`date +%F--%H-%M`] Backup path mount is skipped. Backup type: $2."
fi

# Make path with subfolders
mkdir -p $FILE_PATH
echo "[----------][`date +%F--%H-%M`] Backup path foldes is created"

# Make backups for every /home subdirectory separately
echo "[----------][`date +%F--%H-%M`] Start making backup files for each /home subdirectory"
cd /home
for directory in $(find -maxdepth 1 -not -name "*lost+found" -not -name "." -type d)
do 
    dir_name=${directory:2}
    echo "[----------][`date +%F--%H-%M`] Make backup files for $dir_name"
    tar cj $dir_name | gpg --recipient p0vidl0 --encrypt > "$FILE_PATH/$dir_name-$(date +$TIMESTAMP).tar.bz2.gpg"
done
echo "[----------][`date +%F--%H-%M`] Done making backup files for each /home subdirectory"

echo "[----------][`date +%F--%H-%M`] Making backup files HTTPD config files $HTTPD_CONF_PATH"
tar cj $HTTPD_CONF_PATH | gpg --recipient p0vidl0 --encrypt > "$FILE_PATH/httpd-$(date +$TIMESTAMP).tar.bz2.gpg"
echo "[----------][`date +%F--%H-%M`] Done making backup files HTTPD config files $HTTPD_CONF_PATH"

# Remove old backup files
if [[ "$ROTATION_DAYS" -gt 0 ]]
then
echo "[----------][`date +%F--%H-%M`] Rotating backup files: find $FILE_PATH -type f -mtime +$ROTATION_DAYS -delete"
find $FILE_PATH -type f -mtime +$ROTATION_DAYS -delete
else
echo "[----------][`date +%F--%H-%M`] Skip rotating backup files."
fi

# umount remote path
if [[ "$2" = "remote" ]]
then
umount $BACKUP_PATH
echo "[----------][`date +%F--%H-%M`] Backup path is unmounted"
else
echo "[----------][`date +%F--%H-%M`] Backup path umount is skipped. Backup type: $2."
fi
echo "[----------][`date +%F--%H-%M`] All done. Exiting."
exit 0
