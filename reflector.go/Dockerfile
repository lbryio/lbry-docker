## base image for github.com/lbryio/reflector.go release binaries
FROM golang:1.11.1 as builder
LABEL MAINTAINER="leopere [at] nixc [dot] us"

RUN export GOROOT=$GOPATH/bin && \
    go get -v -u github.com/lbryio/reflector.go && \
    cd "/go/src/github.com/lbryio/reflector.go" && \
    make && \
    mv ./bin/prism-bin /usr/bin/prism-bin && \
    chmod +x /usr/bin/prism-bin

## base image for github.com/lbryio/reflector.go release binaries
FROM ubuntu:18:04 as app
LABEL MAINTAINER="leopere [at] nixc [dot] us"

COPY /go/src/github.com/lbryio/reflector.go/bin/prism-bin /usr/bin/prism-bin
COPY start.sh /usr/local/bin/start
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN adduser reflector --gecos GECOS --shell /bin/bash --disabled-password --home /data/ && \
    apt-get update && \
    apt-get -y install && \
    wget -O /data/config.tmpl https://raw.githubusercontent.com/lbryio/reflector.go/master/config.tmpl && \
    chown -R 1000:1000 /data/config.tmpl

USER reflector

CMD ["start"]
