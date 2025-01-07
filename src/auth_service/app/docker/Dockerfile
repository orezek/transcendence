# Use the official Ruby image
FROM ruby:3.3.6
# Set the working directory inside the container

RUN apt-get update && apt-get install -y \
    ruby-dev \
    build-essential \
    libpq-dev \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN gem install bundler && \
    gem install ruby-debug-ide && \
    gem install debase

COPY ./docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY ./Gemfile ./Gemfile.lock /
RUN bundle install --no-cache

RUN mkdir -p /usr/src/auth_service

WORKDIR /usr/src/auth_service

CMD ["/usr/local/bin/entrypoint.sh"]
# Set the default command to run the Ruby script
#CMD ["ruby", "./auth_service.rb", "-o", "0.0.0.0"]
