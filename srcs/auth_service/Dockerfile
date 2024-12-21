FROM ruby:3.3.6

# System dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    ruby-dev \
    libpq-dev \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Install debug gems globally
RUN gem install bundler && \
    gem install ruby-debug-ide && \
    gem install debase

COPY Gemfile Gemfile.lock ./
RUN bundle install --no-cache

# Create DEBUG script outside of the mounted volume
RUN echo '#!/bin/bash\n\
cd /usr/src/app\n\
bundle install\n\
echo "Starting debugger..."\n\
rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 -- ./app.rb -o 0.0.0.0\n\
' > /usr/local/bin/debug.sh


# Create NO_DEBUG script outside of the mounted volume
RUN echo '#!/bin/bash\n\
cd /usr/src/app\n\
bundle install\n\
ruby ./app.rb -o 0.0.0.0\n\
' > /usr/local/bin/no_debug.sh

# Create run script to choose between debug and normal mode
RUN echo '#!/bin/bash\n\
if [ "$PROFILE" = "debug" ]; then\n\
  echo "Running in debug mode"\n\
  /usr/local/bin/debug.sh\n\
else\n\
  echo "Running in normal mode"\n\
  /usr/local/bin/no_debug.sh\n\
fi\n' > /usr/local/bin/run.sh

# Make scripts executable
RUN chmod +x /usr/local/bin/debug.sh /usr/local/bin/no_debug.sh /usr/local/bin/run.sh


WORKDIR /usr/src/app

CMD ["/usr/local/bin/run.sh"]