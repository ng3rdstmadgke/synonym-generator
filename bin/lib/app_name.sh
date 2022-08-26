#!/bin/bash
PROJECT_ROOT="$(cd $(dirname $0)/../..; pwd)"
APP_NAME=$(cat ${PROJECT_ROOT}/APPNAME | tr '[A-Z]' '[a-z]')
echo $APP_NAME