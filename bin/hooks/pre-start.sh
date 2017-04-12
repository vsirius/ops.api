#!/bin/sh
# `pwd` should be /opt/ops_api
APP_NAME="ops_api"

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/$APP_NAME command "${APP_NAME}_tasks" migrate!
fi;
