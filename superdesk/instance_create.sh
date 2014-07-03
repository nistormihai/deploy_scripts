#!/bin/sh

[ -z "$4" ] &&
echo "Usage: $0 INSTANCE_NAME INSTANCE_SERVER_NAME PORT REDIS_DB_ID" &&
echo "       $0 master master.sd-test.sourcefabric.org 9090 1" &&
exit 1


INSTANCE="$1"
SERVER_NAME="$2"
PORT="$3"
REDIS_DB_ID="$4"

NGINX_PORT=82 # frontend port of nginx
ROOT=/var/opt/superdesk_instances # superdesk instances root
PWD=$(dirname $0)
INSTANCE_ROOT=$ROOT/$INSTANCE
LOG_PATH=$INSTANCE_ROOT/logs


# create necessary folders if needed
mkdir -p $INSTANCE_ROOT ;
mkdir -p $LOG_PATH ;

# assign free port to application
#APP_STARTING_PORT=9090 # starting port for app
#rm $INSTANCE_ROOT/.port 2>/dev/null ;
#PORT=$(expr $(cat $ROOT/*/.port | sort -nr | head -n 1) + 1) 2>/dev/null ;
#[ $PORT -le $APP_STARTING_PORT ] && PORT=$APP_STARTING_PORT ;
#echo $PORT > $INSTANCE_ROOT/.port &&


# generate nginx vhost
. $PWD/templates/nginx.tpl > /etc/nginx/sites-enabled/superdesk_$INSTANCE &&
service nginx reload &&

# generate supervisor config
. $PWD/templates/supervisor.tpl > /etc/supervisor/conf.d/superdesk_$INSTANCE.conf &&
supervisorctl reread &&

mkdir -p /var/www/sd-test/$INSTANCE ;
. $PWD/templates/index.html.tpl > /var/www/sd-test/$INSTANCE/index.html &&

exit 0
