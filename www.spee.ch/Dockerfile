## Base Image
## Using the smallest container available
## https://hub.docker.com/_/node/
# 8.11.2-alpine, 8.11-alpine, 8-alpine, carbon-alpine (8/alpine/Dockerfile)
FROM node:8-alpine
MAINTAINER chamunks [at] gmail [dot] com

## Install base packages and clone repo to src directory.
RUN apk update && apk --no-cache add git curl wget python build-base bash && \
    npm update && npm i npm@latest -g && \
    npm install -g node-gyp && \
    adduser speech -h /app/ -s /bin/bash -D && \
    chown -Rv speech /app && \
    git clone https://github.com/lbryio/spee.ch.git /usr/local/src/spee.ch/ && \
    cd /usr/local/src/spee.ch/ && \
    npm install

## Install container support files
RUN curl -s https://raw.githubusercontent.com/chamunks/docker-support/master/install | /bin/sh
ADD ./docker-entrypoint.sh /bin/docker-entrypoint
ADD ./healthcheck.sh /bin/healthcheck

HEALTHCHECK CMD healthcheck
EXPOSE 3000
USER speech
WORKDIR /app/
ENTRYPOINT ["docker-entrypoint"]
CMD ["npm", "run", "start:dev"]
