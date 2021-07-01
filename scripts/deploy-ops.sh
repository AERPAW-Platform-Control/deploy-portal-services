#!/usr/bin/env bash
# NOTE: run this script from the scripts directory
source ../.env

# configuration
SERVER_BUILD_WAIT_TIME=45
SCRIPTS_DIR=$(pwd)
WORK_DIR=$(dirname ${SCRIPTS_DIR})

# pull git repositories
cd $WORK_DIR
git clone ${AERPAW_GIT_URL}/${PORTAL_REPO}.git
git clone ${AERPAW_GIT_URL}/${GATEWAY_REPO}.git
git clone ${AERPAW_GIT_URL}/${CICD_REPO}.git
cd $SCRIPTS_DIR
exit 0;

# wait for server to start up
echo "[INFO] waiting for server to start up"
for pc in $(seq ${SERVER_BUILD_WAIT_TIME} -1 1); do
  echo -ne "$pc ...\033[0K\r" && sleep 1
done
echo ""