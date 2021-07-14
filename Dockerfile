# Dockerfile
FROM ruby:3.0.2-buster

# Install ruby and ruby-bundler
RUN rm -rf /var/cache/apk/*
WORKDIR /code
COPY . /code
RUN bundle install
RUN rm -rf node_modules tmp/cache app/assets vendor/assets spec

EXPOSE 8080
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "8080"]
