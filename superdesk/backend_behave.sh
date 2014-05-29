#!/bin/bash

[ -z "$2" ] &&
echo "Usage: $0 INSTANCE_NAME" &&
echo "       $0 master" &&
exit 1


PLAN_PATH=$(dirname $0)"/../../"
INSTANCE="$1"
INSTANCE_PATH=/var/opt/superdesk_instances/$INSTANCE
BACKEND_PATH=$INSTANCE_PATH/backend


# create/reuse virtual environment
[ ! -f $INSTANCE_PATH/env/bin/activate ] && (
    virtualenv-3.4 -p python3.3 $INSTANCE_PATH/env;
)
. $INSTANCE_PATH/env/bin/activate &&

# run test
cd $BACKEND_PATH &&
behave --junit --junit-directory $PLAN_PATH/behave_results ;

exit 0
