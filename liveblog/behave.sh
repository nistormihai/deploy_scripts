#!/bin/bash
# $1 branch name

export LC_ALL="en_US.utf8"

plan_path=$(dirname $0)
test_path=$(readlink -e $plan_path/../../liveblog/rest_tests)
root_path=/var/opt/instances/"$1"


[ ! -f "$root_path"/env_test/bin/activate ] && (
    virtualenv -p python3 "$root_path"/env_test;
)
. "$root_path"/env_test/bin/activate;


cd "$test_path"


pip uninstall -y behave wooper
pip install --upgrade pip distribute
#pip install --upgrade -r requirements.txt
./install_requirements.sh


echo SERVER_URL = \"http://$1.lb-test.sourcefabric.org/resources/\" > $test_path/settings_local.py
cat $test_path/settings_local.py


# clean-up test results
rm $plan_path/behave_results/  2>/dev/null
mkdir $plan_path/behave_results/  2>/dev/null


# run tests
behave --junit --junit-directory $plan_path/behave_results ;


exit 0
#touch -t $(date -d "1 sec" +%Y%m%d%H%M.%S) $test_path/results/tests.xml
#ls -l $plan_path/results/tests.xml
