FROM ruby:2.7.2-alpine

RUN echo "install: --no-document" >> /etc/gemrc

# Minimal requirements to run a Rails app
RUN apk add --no-cache --update build-base \
                                linux-headers \
                                git \
                                postgresql-dev \
                                nodejs \
                                yarn \
                                tzdata
RUN yarn --version
RUN gem install bundler -v 2.2.4

ENV APP_PATH /app
WORKDIR $APP_PATH
ADD Gemfile $APP_PATH
ADD Gemfile.lock $APP_PATH
COPY package.json yarn.lock $APP_PATH/

RUN bundle install --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1`
RUN yarn

COPY . $APP_PATH/

CMD ["bundle", "exec", "rails", "server", "-p", "3000", "-b", "0.0.0.0"]
