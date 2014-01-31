#!/bin/sh

APP="$bamboo_app"
DEVELOPER="$bamboo_developer"
test ! -z "$bamboo_lab" && LAB_INSTANCE="$bamboo_lab" || LAB_INSTANCE="prelive"
PORT="$bamboo_port"

REMOTE_PATH="/var/www/""$APP""-"$LAB_INSTANCE"/backup/backup-*.tar.gz"
LOCAL_PATH="/var/dumps/""$APP""/backup.tar.gz"

ssh -p$PORT lab@"$DEVELOPER".sourcefabric.net -x "sudo mkdir -p /var/dumps/$APP"
echo rsync -a --rsh="ssh -p$PORT" --protect-args --rsync-path="sudo rsync" $REMOTE_PATH lab@"$DEVELOPER".sourcefabric.net:"$LOCAL_PATH"
rsync -a --rsh="ssh -p$PORT" --protect-args --rsync-path="sudo rsync" $REMOTE_PATH lab@"$DEVELOPER".sourcefabric.net:"$LOCAL_PATH"

