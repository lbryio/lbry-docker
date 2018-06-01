## Base Image
FROM node:8-alpine
## Using the smallest container available
## https://hub.docker.com/_/node/
# 8.11.2-alpine, 8.11-alpine, 8-alpine, carbon-alpine (8/alpine/Dockerfile)

MAINTAINER chamunks [at] gmail [dot] com

RUN npm update && \
    apk update && apk --no-cache add git && \
    adduser speech -h /app/ -s /bin/ash -D && \
    chown -Rv speech /app && \
    git clone https://github.com/lbryio/www.spee.ch.git /src/spee.ch/

EXPOSE 3000

USER speech
WORKDIR /app/
ENTRYPOINT ["docker-entrypoint"]
CMD ["npm", "run", "start:dev"]
