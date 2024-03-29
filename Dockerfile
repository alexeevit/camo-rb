ARG RUBY_VERSION=2.7

FROM ruby:$RUBY_VERSION-slim-buster

RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential

# Configure bundler
ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

# Update rubygems
RUN gem update --system

# Create a directory for the app code
RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock .

RUN bundle install

COPY . .

CMD ["/app/bin/camorb"]
