cat <<EOF
[program:superdesk_$INSTANCE]
directory=$INSTANCE_ROOT/backend
command=$INSTANCE_ROOT/env/bin/python $INSTANCE_ROOT/env/bin/gunicorn wsgi
    -w 4 -b 127.0.0.1:$PORT
environment=
    PATH="$INSTANCE_ROOT/env/bin:$PATH",
    SUPERDESK_URL="https://$SERVER_NAME/api",
    MONGO_DBNAME="superdesk_$INSTANCE",
    AMAZON_ACCESS_KEY_ID="$bamboo_AMAZON_ACCESS_KEY_ID",
    AMAZON_CONTAINER_NAME="$bamboo_AMAZON_CONTAINER_NAME",
    AMAZON_REGION="$bamboo_AMAZON_REGION",
    AMAZON_SECRET_ACCESS_KEY="$bamboo_AMAZON_SECRET_ACCESS_KEY",
    CELERY_BROKER_URL="redis://localhost:6379/superdesk_$INSTANCE",
    CELERY_RESULT_BACKEND="redis://localhost:6379/superdesk_$INSTANCE",
    CELERY_ALWAYS_EAGER="False"
stdout_logfile=$LOG_PATH/app_stdout
stderr_logfile=$LOG_PATH/app_stderr

[program:superdesk_celery_$INSTANCE]
directory=$INSTANCE_ROOT/backend
command=$INSTANCE_ROOT/env/bin/celery worker -A worker.celery
environment=
    PATH="$INSTANCE_ROOT/env/bin:$PATH",
    SUPERDESK_URL="https://$SERVER_NAME/api",
    MONGO_DBNAME="superdesk_$INSTANCE",
    AMAZON_ACCESS_KEY_ID="$bamboo_AMAZON_ACCESS_KEY_ID",
    AMAZON_CONTAINER_NAME="$bamboo_AMAZON_CONTAINER_NAME",
    AMAZON_REGION="$bamboo_AMAZON_REGION",
    AMAZON_SECRET_ACCESS_KEY="$bamboo_AMAZON_SECRET_ACCESS_KEY",
    CELERY_BROKER_URL="redis://localhost:6379/$REDIS_DB_ID",
    CELERY_RESULT_BACKEND="redis://localhost:6379/$REDIS_DB_ID",
    CELERY_ALWAYS_EAGER="False",
    C_FORCE_ROOT="True"
stdout_logfile=$LOG_PATH/celery_stdout
stderr_logfile=$LOG_PATH/celery_stderr
EOF
