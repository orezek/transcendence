#!/bin/bash

cd /usr/src/auth_service/app

if [ "$PROFILE" = "debug" ]; then
  echo "Running in debug mode"
  exec rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26164 -- ./auth_service.rb -o 0.0.0.0
else
  echo "Running in normal mode"
  exec ruby ./auth_service.rb -o 0.0.0.0
fi
