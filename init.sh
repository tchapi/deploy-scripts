#!/bin/bash
# Init script for further deployment

# Configuration :

# Live
LIVE_BRANCH='live'
LIVE_DIRECTORY='prod'

# Staging
STAGING_BRANCH='staging'
STAGING_DIRECTORY='beta'

# Deploy and WWW directories
DEPLOY_DIRECTORY='deploy'
WWW_DIRECTORY='www'

# Global colors
YELLOW='\033[01;33m'  # bold yellow
RED='\033[01;31m' # bold red
GREEN='\033[01;32m' # green
BLUE='\033[01;34m'  # blue
RESET='\033[00;00m' # normal white

if [ $# -lt 2 ]
then
  echo ""
  echo -e ${GREEN}" Project initialisation script "${RESET}
  echo " Usage: $0 (application-name) (git-repository)"
  echo ""
  exit 1
fi

name=$1
url=$2

if ! curl --output /dev/null --silent --head --fail "$url"; then
  echo ""
  echo -e ${GREEN}" Project initialisation script "${RESET}
  echo -e ${RED}" Error: "${RESET}"$url is not a valid url"
  echo ""
  exit 1
fi

# Initializing the repos

cd ${APP_BASE_PATH}/${DEPLOY_DIRECTORY}/
mkdir $name

# Installing STAGING environment

cd ${APP_BASE_PATH}/${DEPLOY_DIRECTORY}/${name}
mkdir ${STAGING_DIRECTORY}

cd ${APP_BASE_PATH}/${DEPLOY_DIRECTORY}/${name}/${STAGING_DIRECTORY}
git init
git remote add -t ${STAGING_BRANCH} -f origin $url
git checkout ${STAGING_BRANCH}

if [ -e "composer.json" ]
then

  php composer.phar self-update
  php composer.phar install --prefer-dist

  cd web
  ln -s ../../uploads uploads

fi

# Installing PROD environment

cd ${APP_BASE_PATH}/${DEPLOY_DIRECTORY}/${name}
mkdir ${LIVE_DIRECTORY}

cd ${APP_BASE_PATH}/${DEPLOY_DIRECTORY}/${name}/${LIVE_DIRECTORY}
git init
git remote add -t ${LIVE_BRANCH} -f origin $url
git checkout ${LIVE_BRANCH}

if [ -e "composer.json" ]
then

  php composer.phar self-update
  php composer.phar install --prefer-dist

  cd web
  ln -s ../../uploads uploads

fi

# Creating Web folders

cd ${APP_BASE_PATH}/${WWW_DIRECTORY}/
mkdir $name

cd ${APP_BASE_PATH}/${WWW_DIRECTORY}/${name}
mkdir uploads
chmod 777 uploads

# Summary

echo -e ${RESET}
echo -e " # "${GREEN}"Created environnements :"
echo -e " |  - Staging "
echo -e " |    "${YELLOW}"Deploy path : "${RESET}${APP_BASE_PATH}/${DEPLOY_DIRECTORY}/${name}/${STAGING_DIRECTORY}
echo -e " |    "${YELLOW}" --> tracking branch "${RESET}${STAGING_BRANCH}${YELLOW}" of remote "${RESET}${url}

echo -e " |  - Live "
echo -e " |    "${YELLOW}"Deploy path : "${RESET}${APP_BASE_PATH}/${DEPLOY_DIRECTORY}/${name}/${LIVE_DIRECTORY}
echo -e " |    "${YELLOW}" --> tracking branch "${RESET}${LIVE_BRANCH}${YELLOW}" of remote "${RESET}${url}

echo -e " |  - Web Server "
echo -e " |    "${BLUE}"Apache path : "${RESET}${APP_BASE_PATH}/${WWW_DIRECTORY}/${name}
echo ""

# Done
echo -e ${RESET}
echo -e " # "${GREEN}"Done. "${RESET}"Exiting."
echo ""
