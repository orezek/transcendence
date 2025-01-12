FROM ruby:3.4.1-slim-bookworm

RUN apt-get update && apt-get install -y \
    ruby-dev \
    build-essential \
    libpq-dev \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*


COPY Gemfile /
RUN bundle install --no-cache

# Create non-root user
RUN groupadd --system --gid 1001 app_user && \
   useradd --system --uid 1001 --gid app_user app_user

# Create and set working directory
WORKDIR /status_service

## Copy application code
COPY --chown=app_user:app_user ./presence_service.rb ./presence_service.rb

# Switch to non-root user
USER app_user:app_user
# Start the application
CMD ["bundle", "exec", "ruby", "presence_service.rb"]