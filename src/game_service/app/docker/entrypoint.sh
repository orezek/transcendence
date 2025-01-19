#!/bin/bash

cd /usr/src/game_service/app

if [ "$PROFILE" = "debug" ]; then
  echo "Running in debug mode"
  exec rdebug-ide --host 0.0.0.0 --port 1235 --dispatcher-port 26165 -- ./game_service.rb -o 0.0.0.0
else
  echo "Running in normal mode"
  exec rerun --background -- "ruby ./game_service.rb -o 0.0.0.0"
fi