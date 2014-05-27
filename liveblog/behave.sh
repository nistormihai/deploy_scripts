#!/bin/bash
# $1 branch name

export LC_ALL="en_US.utf8"

plan_path=$(dirname $0)
test_path=$plan_path/liveblog/rest_tests

rm -fr $test_path
cp -rf ./liveblog_tests $test_path

[ ! -f "$root_path"/env_test/bin/activate ] && (
    virtualenv -p python3 "$root_path"/env_test;
)
. "$root_path"/env_test/bin/activate;

cd "$test_path"


pip install --upgrade pip
pip install --upgrade -r requirements.txt

echo SERVER_URL = \"http://$1.lb-test.sourcefabric.org/\" > $test_path/settings_local.py
cat $test_path/settings_local.py

# clean-up test results
rm $plan_path/behave_results/  2>/dev/null
mkdir $plan_path/behave_results/  2>/dev/null

# run tests
behave --junit --junit-folder=$plan_path/behave_results &&

exit 0

#touch -t $(date -d "1 sec" +%Y%m%d%H%M.%S) $test_path/results/tests.xml
#ls -l $plan_path/results/tests.xml
