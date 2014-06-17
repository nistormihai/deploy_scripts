#!/bin/sh

[ -z "$2" ] &&
echo "Usage: $0 INSTANCE_NAME INSTANCE_SERVER_NAME" &&
echo "       $0 master master.sd-test.sourcefabric.org" &&
exit 1


INSTANCE="$1"
SERVER_NAME="$2"
NGINX_PORT=82 # frontend port of nginx
APP_STARTING_PORT=9090 # starting port for app
REDIS_StARTING_ID=2
ROOT=/var/opt/superdesk_instances # superdesk instances root
PWD=$(dirname $0)
INSTANCE_ROOT=$ROOT/$INSTANCE
LOG_PATH=$INSTANCE_ROOT/logs


# create necessary folders if needed
mkdir -p $INSTANCE_ROOT ;
mkdir -p $LOG_PATH ;

# assign free port to application
rm $INSTANCE_ROOT/.port 2>/dev/null ;
PORT=$(expr $(cat $ROOT/*/.port | sort -nr | head -n 1) + 1) 2>/dev/null ;
[ $PORT -le $APP_STARTING_PORT ] && PORT=$APP_STARTING_PORT ;
echo $PORT > $INSTANCE_ROOT/.port &&

# assign free db index to celery
rm $INSTANCE_ROOT/.redis_db_index 2>/dev/null ;
REDIS_DB_ID=$(expr $(cat $ROOT/*/.redis_db_index | sort -nr | head -n 1) + 1) 2>/dev/null ;
[ $REDIS_DB_ID -le $REDIS_StARTING_ID ] && REDIS_DB_ID=$REDIS_StARTING_ID ;
echo $REDIS_DB_ID > $INSTANCE_ROOT/.redis_db_index &&

# generate nginx vhost
. $PWD/templates/nginx.tpl > /etc/nginx/sites-enabled/superdesk_$INSTANCE &&
service nginx reload &&

# generate supervisor config
. $PWD/templates/supervisor.tpl > /etc/supervisor/conf.d/superdesk_$INSTANCE.conf &&
supervisorctl reread &&

mkdir -p /var/www/sd-test/$INSTANCE ;
. $PWD/templates/index.html.tpl > /var/www/sd-test/$INSTANCE/index.html &&

exit 0
