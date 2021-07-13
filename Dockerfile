# Dockerfile
FROM ruby:2.7.4-buster
#FROM ruby:2.7.1

WORKDIR /code
COPY . /code
RUN gem install bundler:2.2.15
RUN bundle update mustermann
RUN bundle install

EXPOSE 8080

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "8080"]
