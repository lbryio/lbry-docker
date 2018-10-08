## base image for github.com/lbryio/reflector.go release binaries
FROM golang:1.11.1
MAINTAINER chamunks [at] gmail [dot] com

ADD start.sh /usr/local/bin/start
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN adduser reflector --gecos GECOS --shell /bin/bash --disabled-password --home /data/

RUN go get -u github.com/lbryio/reflector.go && \
    cd "$(go env GOPATH)/src/github.com/lbryio/reflector.go" && \
    make && \
    cp ./bin/prism-bin /usr/bin/prism-bin && \
    chmod +x /usr/bin/prism-bin

USER reflector

#EXPOSE No idea yet.
