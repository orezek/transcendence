#!/bin/bash

# Check if Gemfile exists
if [ -f "Gemfile" ]; then
  echo "Gemfile detected, installing dependencies..."
  bundle install
else
  echo "No Gemfile found. Skipping bundle install."
fi

# Run the main container command
exec "$@"
