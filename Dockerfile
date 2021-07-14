# Dockerfile
FROM alpine:latest

RUN apk update && apk add --no-cache build-base
RUN apk add curl wget bash
# Install ruby and ruby-bundler
RUN apk add ruby-dev libpq postgresql-dev ruby-io-console ruby-bundler
RUN rm -rf /var/cache/apk/*
WORKDIR /code
COPY . /code
RUN bundle install

# Remove folders not needed in resulting image
RUN rm -rf node_modules tmp/cache app/assets vendor/assets spec

EXPOSE 8080

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "8080"]
