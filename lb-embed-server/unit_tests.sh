#!/bin/sh

root=/var/www/nodejs-dev

working_dir=$(readlink -e $(dirname $0))

cd $root &&

# run tests
grunt ci:bamboo &&

(
	mkdir -p $working_dir/../../results/ 2> /dev/null;
	mv server-test-results.xml client-test-results.xml $working_dir/../../results/
) &&

exit 0
