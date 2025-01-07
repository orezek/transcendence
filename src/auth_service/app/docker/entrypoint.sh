#!/bin/bash

cd /usr/src/auth_service/app
echo $(pwd)
# Check if Gemfile exists
#if [ -f "Gemfile" ]; then
#  echo "Gemfile detected, installing dependencies..."
#  bundle install
#else
#  echo "No Gemfile found. Skipping bundle install."
#fi

if [ "$PROFILE" = "debug" ]; then
  echo "Running in debug mode"
  exec rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- ./app/auth_service.rb -o 0.0.0.0
else
  echo "Running in normal mode"
  exec ruby ./auth_service.rb -o 0.0.0.0
fi
