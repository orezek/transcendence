#!/bin/bash

cd /usr/src/game_service/app

if [ "$PROFILE" = "debug" ]; then
  echo "Running in debug mode"
  exec rdebug-ide --host 0.0.0.0 --port 1235 --dispatcher-port 26162 -- ./app/game_service.rb -o 0.0.0.0
else
  echo "Running in normal mode"
  exec ruby ./game_service.rb -o 0.0.0.0
fi
