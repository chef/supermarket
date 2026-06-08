FROM ruby:3.1.2-slim

# Install system dependencies needed by gems (pg, nokogiri, etc.)
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libpq-dev \
    libssl-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile, lockfile, and local path gems before bundle install (for layer caching)
COPY Gemfile Gemfile.lock ./
COPY engines/ ./engines/

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Ensure entrypoint has Unix line endings and is executable
RUN sed -i 's/\r//' bin/docker-entrypoint.sh && chmod +x bin/docker-entrypoint.sh

# Default: start the Rails server. Override at runtime for other commands.
ENTRYPOINT ["/app/bin/docker-entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
