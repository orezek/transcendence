# Use the official Ruby image
FROM ruby:3.4.1-slim-bookworm


RUN apt-get update && apt-get install -y \
    ruby-dev \
    build-essential \
    libpq-dev \
    iputils-ping \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN gem install bundler

COPY Gemfile /
RUN bundle install --no-cache

# Create non-root user
RUN groupadd --system --gid 1001 app_user && \
    useradd --system --uid 1001 --gid app_user app_user

WORKDIR /auth_service
# Copy application code
COPY --chown=app_user:app_user *.rb ./
COPY --chown=app_user:app_user db_config ./db_config/
COPY --chown=app_user:app_user db_models ./db_models/
# Switch to non-root user
USER app_user:app_user

# Start the application
CMD ["ruby", "auth_service.rb", "-o", "0.0.0.0"]
