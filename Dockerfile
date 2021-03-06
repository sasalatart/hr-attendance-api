FROM ruby:2.6.3

LABEL maintainer="Sebastian Salata R-T <sa.salatart@gmail.com>"

ENV RAILS_ENV=production RAILS_LOG_TO_STDOUT=true

RUN apt-get update -qq && \
  apt-get install -y build-essential libpq-dev nodejs && \
  apt-get clean

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

EXPOSE 3000

CMD ["rails", "server", "puma", "-b", "0.0.0.0"]
