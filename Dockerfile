FROM ruby:2.7.2

ENV LANG C.UTF-8
ENV APP_ROOT /xxx8110io

RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  build-essential \
  nodejs \
  mariadb-client \
  yarn && \
  apt-get clean && \
  rm --recursive --force /var/lib/apt/lists/*

RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

COPY Gemfile $APP_ROOT/Gemfile
COPY Gemfile.lock $APP_ROOT/Gemfile.lock
RUN bundle install --jobs 4 --retry 3
COPY . $APP_ROOT

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]