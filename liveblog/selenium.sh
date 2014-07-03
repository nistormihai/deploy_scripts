#!/bin/bash
# $1 branch name

export LC_ALL="en_US.utf8"

plan_path=$(pwd)
root_path=/var/opt/instances/"$1"
test_path="$root_path"/func_tests

rm -fr $test_path
cp -rf ./liveblog_tests $test_path

[ ! -f "$root_path"/env_test/bin/activate ] && (
    virtualenv -p python3 "$root_path"/env_test;
)
. "$root_path"/env_test/bin/activate;

cd "$test_path"


pip install --upgrade pip
pip install --upgrade -r requirements.txt

echo LIVEBLOG_URL = \"http://$1.lb-test.sourcefabric.org/\" > test_tool/settings_local.py
cat test_tool/settings_local.py

# clean-up test results
mkdir "$plan_path"/results/  2>/dev/null
rm "$plan_path"/results/*.xml  2>/dev/null

# run tests
bash ./headless.sh
mv *.xml "$plan_path"/results/

#touch -t $(date -d "1 sec" +%Y%m%d%H%M.%S) $test_path/results/tests.xml
#ls -l $plan_path/results/tests.xml
