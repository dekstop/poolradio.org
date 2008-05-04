#!/bin/bash

source /etc/profile # sets up PATH 

# check env
pushd `dirname $0`
cd ..
APP_ROOT=$PWD
popd

# exec wrapper
LOGFILE=${APP_ROOT}/log/`basename $0 .sh`.log

function errorNotify() {
    FAILED_CMD=$@
    echo "'$FAILED_CMD' returned with an error."
    (echo "'${FAILED_CMD}' returned with an error. Tail of ${LOGFILE}:"; echo; tail -n 25 $LOGFILE) | mail -s "[`hostname`] error in `basename $0`, ${FAILED_CMD}" martin@dekstop.de
}

function checkResult() {
    CMD=$@
    echo "Executing: ${CMD}"
    echo 
    $CMD || errorNotify $CMD
    echo "-----"
    echo
}


# main
echo "Running daily CRON ..."
date

checkResult ruby ${APP_ROOT}/bots/stations.usertags-feed.rb
checkResult ruby ${APP_ROOT}/bots/stations.toptags-feed.rb
checkResult ruby ${APP_ROOT}/bots/stations.manualrecs-feed.rb
checkResult ruby ${APP_ROOT}/bots/context.wikipedia.rb
