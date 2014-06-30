#!/bin/sh

###Environment variables:###################
# BRANCH=${bamboo.planRepository.branchName}
#############################################

. ./deploy_scripts/nsc/functions.sh

APP="$bamboo_app"
DEVELOPER="$bamboo_developer"
BRANCH=$(url_safe "$BRANCH")

test ! -z "$bamboo_lab" && LAB_INSTANCE="$bamboo_lab" || LAB_INSTANCE="$APP"

BACKUP_PATH=/var/dumps/$APP
INSTALL_DIR=/var/www/$APP/
IMG_SRC="$BACKUP_PATH"/backup-*/images
FILES_SRC="$BACKUP_PATH"/backup-*/files

PASSWORD="$bamboo_password"
DBUSER="$APP"_"$BRANCH"
DBNAME=$(echo "$DBUSER" | cut -c 1-61)_db
DBUSER=$(echo "$DBUSER" | md5sum | cut -c 1-16) # first 16 symbols of md5 hash
DUMP_FILE=lab_"$LAB_INSTANCE"-database.sql
OLD_URL="$LAB_INSTANCE".lab.sourcefabric.org



cd $BACKUP_PATH &&

(
	test -e new_backup &&
	(
		sudo rm -r backup-* new_backup ;
		sudo tar xvf backup.tar.gz
	) || true
) &&

(
	rsync -a --protect-args --rsync-path="sudo rsync" $IMG_SRC $INSTALL_DIR ;
	rsync -a --protect-args --rsync-path="sudo rsync" $FILES_SRC $INSTALL_DIR ;
) &&
chown -R www-data $INSTALL_DIR &&

mysql -p$PASSWORD -e "SET GLOBAL general_log = 'OFF';" ;

echo "drop database \`$DBNAME\` ;" &&
mysql -p$PASSWORD  -e "drop database \`$DBNAME\` ;" ;

echo "create database \`$DBNAME\` ;" &&
mysql -p$PASSWORD  -e "create database \`$DBNAME\` ;" &&

echo "grant all privileges on \`$DBNAME\`.* to \`$DBUSER\`@\`localhost\` identified by '$DBUSER' with grant option;" &&
mysql -p$PASSWORD  -e "grant all privileges on \`$DBNAME\`.* to \`$DBUSER\`@\`localhost\` identified by '$DBUSER' with grant option;" &&

cd backup-* &&
echo "mysql $DBNAME < $DUMP_FILE" &&
mysql -p$PASSWORD  $DBNAME < $DUMP_FILE &&

echo " UPDATE Aliases SET Name='$BRANCH.$APP.$DEVELOPER.sourcefabric.net' WHERE Name='$OLD_URL'" &&
mysql -p$PASSWORD  $DBNAME -e "UPDATE Aliases SET Name='$BRANCH.$APP.$DEVELOPER.sourcefabric.net' WHERE Name='$OLD_URL'" &&

exit 0
