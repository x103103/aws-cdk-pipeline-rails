# Any args used for build stages must be defined here
ARG BUILD_ENV=production
ARG RUBY_VERSION=2.7.2
#ARG SECRET_KEY_BASE=d234324324
#ENV SECRET_KEY_BASE ${SECRET_KEY_BASE}

# Base image to use for bundler
FROM ruby:${RUBY_VERSION} AS base
RUN apt-get update

# Use slim version of base image to keep size down
FROM ruby:${RUBY_VERSION}-slim AS app-base
RUN apt-get update

FROM app-base AS production-app

# Add some basic utils for local development
FROM app-base AS development-app
RUN apt-get install -y \
  grep \
  iputils-ping \
  less \
  procps \
  telnet \
  vim \
  nano

# Dynamically build dependencies into the app image
FROM ${BUILD_ENV}-app AS app-source

# Build the Ruby dependencies
FROM base AS base-build
ENV BUNDLER_VERSION 2.2.24
COPY Gemfile Gemfile.lock ./
RUN gem update --system \
  && gem install bundler -v $BUNDLER_VERSION

# All gem groups for local dev and testing
FROM base-build AS development-build
RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 5

FROM base-build AS production-build
RUN bundle config set --local without 'development test' \
  && bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` --retry 5

# The COPY --from cannot use a variable, so we set up this stage to
# handle that dynamically so we can use this with docker compose
FROM ${BUILD_ENV}-build AS build-source

FROM app-source AS app
RUN apt-get update \
  && apt-get install -y \
    ghostscript \
    imagemagick \
    libpq-dev \
    patch \
    file
COPY --from=build-source /usr/local/bundle/ /usr/local/bundle/
RUN groupadd -r app \
  && useradd -r -m -g app app
USER app
WORKDIR /app
COPY --chown=app . /app
