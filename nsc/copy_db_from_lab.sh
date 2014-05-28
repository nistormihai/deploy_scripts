#!/bin/sh

APP="$bamboo_app"
DEVELOPER="$bamboo_developer"
test ! -z "$bamboo_lab" && LAB_INSTANCE="$bamboo_lab" || LAB_INSTANCE=$APP
PORT="$bamboo_port"

BACKUP_PATH="/var/dumps/""$APP"
REMOTE_PATH="/var/www/"$LAB_INSTANCE"/backup/backup-*.tar.gz"
LOCAL_PATH="/var/dumps/""$APP""/backup.tar.gz"

ssh -p$PORT lab@"$DEVELOPER".sourcefabric.net -x "sudo mkdir -p /var/dumps/$APP"
echo rsync -a --rsh="ssh -p$PORT" --protect-args --rsync-path="sudo rsync" $REMOTE_PATH lab@"$DEVELOPER".sourcefabric.net:"$LOCAL_PATH"
rsync -a --rsh="ssh -p$PORT" --protect-args --rsync-path="sudo rsync" $REMOTE_PATH lab@"$DEVELOPER".sourcefabric.net:"$LOCAL_PATH"

ssh -p$PORT lab@"$DEVELOPER".sourcefabric.net -x "cd $BACKUP_PATH; sudo rm -fr backup-* ; sudo tar xvf backup.tar.gz"
