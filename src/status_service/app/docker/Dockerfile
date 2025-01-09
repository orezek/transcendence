# syntax=docker/dockerfile:1.4

# Builder stage
FROM ruby:3.3-slim-bookworm as builder

# Set environment variables
ENV LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/usr/local/bundle \
    DEBIAN_FRONTEND=noninteractive

# Install essential build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create and set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install dependencies
RUN bundle install --jobs="$BUNDLE_JOBS" \
    --retry="$BUNDLE_RETRY" \
    --without development test

# Final stage
FROM ruby:3.3-slim-bookworm

# Set environment variables
ENV LANG=C.UTF-8 \
    BUNDLE_PATH=/usr/local/bundle \
    RACK_ENV=production \
    DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --system --gid 1001 app && \
    useradd --system --uid 1001 --gid app app

# Create and set working directory
WORKDIR /app

# Copy gems from builder stage
COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH

# Copy application code
COPY --chown=app:app . .

# Switch to non-root user
USER app:app

# Health check (adjust the port and endpoint based on your Sinatra configuration)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ruby -r net/http -e 'Net::HTTP.get_response(URI("http://localhost:4567/health")).code == "200"' || exit 1

# Start the application (adjust the command based on your entry point)
CMD ["bundle", "exec", "ruby", "app.rb"]