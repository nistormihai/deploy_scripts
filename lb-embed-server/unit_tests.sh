#!/bin/sh

root=/var/www/nodejs-dev

working_dir=$(dirname $0)
cd $root

# run tests
grunt ci:bamboo

mkdir -p $working_dir/../../ 2> /dev/null
mv server-test-results.xml client-test-results.xml $working_dir/../../results/
