#!/bin/sh
# MySQL backup with rotation
#
# p0vidl0 © 2015
#
# Parameters:
#   1. Rotation type: required, must be in "daily|weekly|monthly".
#   2. Backup type: required, must be in "local|remote". "remote" will mount and umount backup path.
#   3. Backup path: non-required. Must be without trailing slash "/".
#   4. Date and time stamp format: non-required. Example "%Y-%m-%d-%H-%M-%S".
#####################################################################################################

echo "[--------------------------------[`date +%F--%H-%M`]--------------------------------]" 
echo "[----------][`date +%F--%H-%M`] Run the backup script..."
# Variables
USER="MYSQL_USER"
PASS="MYSQL_PASS"
TIMESTAMP="%Y-%m-%d-%H-%M-%S"
BACKUP_PATH="/mnt/backup.yd"

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
FILE_PATH="$BACKUP_PATH/$HOST/mysql/$ROTATION"
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

# Make backups for every database separately
echo "[----------][`date +%F--%H-%M`] Start making backup files for each database"
for db in $(mysql --user=$USER --password=$PASS -e 'show databases' -s --skip-column-names|grep -viE '(performance_schema|information_schema)')
do 
    echo "[----------][`date +%F--%H-%M`] Make backup files for $db database"
    mysqldump --user=$USER --password=$PASS --events --single-transaction $db | bzip2 | gpg --recipient p0vidl0 --encrypt > "$FILE_PATH/$db-$(date +$TIMESTAMP).sql.bz2.gpg"
done
echo "[----------][`date +%F--%H-%M`] Done making backup files for each database"

# Remove old backup files
if [[ "$ROTATION_DAYS" -gt 0 ]]
then
echo "[----------][`date +%F--%H-%M`] Rotating backup files: find $BACKUP_PATH/$HOST/mysql/$ROTATION -type f -mtime +$ROTATION_DAYS -delete"
find $BACKUP_PATH/$HOST/mysql/$ROTATION -type f -mtime +$ROTATION_DAYS -delete
else
echo "[----------][`date +%F--%H-%M`] Skip rotating backup files."
fi

# mount remote path
if [[ "$2" = "remote" ]]
then
umount $BACKUP_PATH
echo "[----------][`date +%F--%H-%M`] Backup path is unmounted"
else
echo "[----------][`date +%F--%H-%M`] Backup path umount is skipped. Backup type: $2."
fi
echo "[----------][`date +%F--%H-%M`] All done. Exiting."
exit 0
