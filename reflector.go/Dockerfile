## base image for github.com/lbryio/reflector.go release binaries
FROM ubuntu:18:04
LABEL MAINTAINER="chamunks [at] gmail [dot] com"

COPY start.sh /usr/local/bin/start
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN adduser reflector --gecos GECOS --shell /bin/bash --disabled-password --home /data/ && \
    apt-get update && \
    apt-get -y install 
