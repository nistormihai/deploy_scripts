#!/bin/sh

root=/var/www/nodejs-dev

backend_url="$1"
backend_port="$2"
frontend_url="$3"
[ "$2" = "" ] &&
		echo "Usage: $0 backend_url backend_port [frontend_url]" &&
		exit 1
[ "$3" = "" ] &&
		frontend_url=$backend_url

# prepare and copy srcs
working_dir=$(readlink -e $(dirname $0))
cd $root

# generate config
. $working_dir/files/config.json.tpl > config.json

# restart server
grunt server:forever:stop
grunt server:forever:start
