# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.3.1

# ── Development ────────────────────────────────────────────────────────────────
FROM ruby:${RUBY_VERSION}-slim AS development

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      git \
      libpq-dev \
    && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=development \
    BUNDLE_PATH=/usr/local/bundle \
    PATH="/rails/bin:/usr/local/bundle/bin:${PATH}"

COPY bin/docker-entrypoint /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

EXPOSE 3000
ENTRYPOINT ["docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]


# ── Base (shared production layers) ───────────────────────────────────────────
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libpq5 \
    && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development test" \
    PATH="/rails/bin:/usr/local/bundle/bin:${PATH}"


# ── Build ──────────────────────────────────────────────────────────────────────
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf "${BUNDLE_PATH}"/ruby/*/cache \
           "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy app and precompile
COPY . .
RUN bundle exec bootsnap precompile app/ lib/
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile


# ── Production ─────────────────────────────────────────────────────────────────
FROM base AS production

# Copy built gems and app
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd --system --uid 1000 --gid 1000 --create-home --shell /bin/bash rails && \
    chown -R rails:rails db log storage tmp

COPY bin/docker-entrypoint /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

USER rails

EXPOSE 3000
ENTRYPOINT ["docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
