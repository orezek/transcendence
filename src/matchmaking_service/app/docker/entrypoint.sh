#!/bin/bash

cd /usr/src/matchmaking_service/app

if [ "$PROFILE" = "debug" ]; then
  echo "Running in debug mode"
  exec rdebug-ide --host 0.0.0.0 --port 1236 --dispatcher-port 26166 -- ./matchmaking_service.rb -o 0.0.0.0
else
  echo "Running in normal mode"
  exec rerun --background -- "ruby ./matchmaking_service.rb -o 0.0.0.0"
fi

