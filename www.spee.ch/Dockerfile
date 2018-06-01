MAINTAINER chamunks [at] gmail [dot] com
## Base Image
## Using the smallest container available
## https://hub.docker.com/_/node/
# 8.11.2-alpine, 8.11-alpine, 8-alpine, carbon-alpine (8/alpine/Dockerfile)
FROM node:8-alpine


## Install base packages and clone repo to src directory.
RUN npm update && \
    apk update && apk --no-cache add git curl wget && \
    adduser speech -h /app/ -s /bin/ash -D && \
    chown -Rv speech /app && \
    git clone https://github.com/lbryio/www.spee.ch.git /usr/local/src/www.spee.ch/

## Install container support files
RUN source <(curl -s https://raw.githubusercontent.com/chamunks/docker-support/master/bin/install)
ADD ./docker-entrypoint.sh /bin/docker-entrypoint

EXPOSE 3000
USER speech
WORKDIR /app/
ENTRYPOINT ["docker-entrypoint"]
CMD ["npm", "run", "start:dev"]
