#!/bin/bash

#Environment variables
# BRANCH=${bamboo.planRepository.branchName}
###

. ./deploy_scripts/nsc/functions.sh

#{{{ Variables
APP="$bamboo_app"
BRANCH=$(url_safe "$BRANCH")
DEVELOPER="$bamboo_developer"
URL="$BRANCH.$APP.$DEVELOPER.sourcefabric.net"

GREP_STR='test_for_this_app_is_not_defined'
test $APP = "anchorage" &&
	GREP_STR='To be able to access all articles' # default?
test $APP = "averdade" &&
	GREP_STR='Voltar ao Jornal '
test $APP = "averdade2" &&
	GREP_STR='Voltar ao Jornal '
test $APP = "broadcaster" &&
	GREP_STR='Broadcaster - Airtime Theme for Newscoop'
test $APP = "elfaro" &&
	GREP_STR='El Faro'
test $APP = "globalnews" &&
	GREP_STR='Global '
test $APP = "journalb" &&
	GREP_STR='Journal B'
test $APP = "meydan" &&
	GREP_STR='Meydan TV'
test $APP = "newcustodian" &&
	GREP_STR='Council' # it's default data
test $APP = 'quetzal' &&
	GREP_STR='Council' # it's default data
test $APP = 'rockstar' &&
	GREP_STR='Rockstar Magazine Theme'
test $APP = 'sourcefabric' &&
	GREP_STR='Sourcefabric'
test $APP = 'tommy' &&
	GREP_STR='Tommy'
test $APP = 'tw' &&
	GREP_STR='Die Wochenzeitung'
test $APP = 'valjevske' &&
	GREP_STR='Nezavisne internet novine Kolubarskog okruga'
test $APP = "wacsi" &&
	GREP_STR='About WACSI'
test $APP = "zentralplus" &&
	GREP_STR='Zentralschweiz'
#}}}

TESTS=1
ERRORS=0
FAILURES=0
SKIP=0

#{{{ TestCase
START_TIME=$(date +%s)
DOC=$(curl "$URL") > /dev/null || ERRORS=1
TEST=$(echo "$DOC" | grep "$GREP_STR")
TIME=$(expr $(date +%s) - $START_TIME)

echo '<testcase classname="classname" name="our_test_name" time="'$TIME'">' >> tmp.xml
if test $ERRORS -ne 0
then
   echo '<error type="execution_error">' >> tmp.xml
   echo 'some error occured, check out the logs\n</error>' >> tmp.xml
fi
if test -z "$TEST"
then
   FAILURES=1
   echo '<error type="assertion_error">' >> tmp.xml
   echo "no '$GREP_STR' text found on page ""$URL""</error>" >> tmp.xml
fi
echo '</testcase>' >> tmp.xml
#}}}

#{{{ Writing test results:
echo '<?xml version="1.0" encoding="UTF-8"?>' > results.xml
echo '<testsuite name="nosetests" tests="'$TESTS'" errors="'$ERRORS'" failures="'$FAILURES'" skip="'$SKIP'">' >> results.xml
cat tmp.xml >> results.xml
echo '</testsuite>' >> results.xml
rm tmp.xml
touch -t $(date -d "1 sec" +%Y%m%d%H%M.%S) results.xml
#}}}

