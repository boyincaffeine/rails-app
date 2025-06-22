# ---- Base Stage ----
FROM ruby:3.1.2-slim-bullseye AS base
ENV LANG C.UTF-8
ENV RAILS_ENV=production
WORKDIR /rails

# ---- Build Stage ----
FROM base AS build
# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs $(nproc) --retry 3

# ---- Final Stage ----
FROM base
# Install production dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Copy built gems and application code
COPY --from=build /usr/local/bundle/ /usr/local/bundle/
COPY . .

# Precompile assets
RUN bundle exec rake assets:precompile

# Entrypoint to run database migrations and start the server
ENTRYPOINT ["./entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]