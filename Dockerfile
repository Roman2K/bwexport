# --- Build image
FROM ruby:3.0.1-alpine3.12 as builder
WORKDIR /home/node

# bundle install deps
RUN apk add --update ca-certificates git build-base openssl-dev
RUN gem install bundler -v '>= 2'

# bundle install
COPY Gemfile* ./
RUN bundle

# --- Runtime image
FROM ruby:3.0.1-alpine3.12
WORKDIR /home/node

COPY --from=builder /usr/local/bundle /usr/local/bundle
RUN apk --update upgrade && apk add --no-cache ca-certificates nodejs npm gnupg
RUN npm install -g @bitwarden/cli@1.17.1

COPY . .
RUN addgroup -g 1000 -S node \
  && adduser -u 1000 -S node -G node \
  && chown -R node: .

USER node
ENTRYPOINT ["bundle", "exec", "ruby", "main.rb"]
