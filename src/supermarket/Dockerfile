FROM ruby:2.1.9

RUN apt-get update -qq
RUN apt-get install -y build-essential libpq-dev nodejs

ENV app /app
RUN mkdir $app
WORKDIR $app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

ADD . $app
