## base image for github.com/lbryio/reflector.go release binaries
FROM golang:1.11.1
LABEL MAINTAINER="leopere [at] nixc [dot] us"

COPY start.sh /usr/local/bin/start
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN adduser reflector --gecos GECOS --shell /bin/bash --disabled-password --home /data/

RUN export GOROOT=$GOPATH/bin && \
    go get -v -u github.com/lbryio/reflector.go && \
    cd "/go/src/github.com/lbryio/reflector.go" && \
    make && \
    mv ./bin/prism-bin /usr/bin/prism-bin && \
    chmod +x /usr/bin/prism-bin

RUN wget -O /data/config.tmpl https://raw.githubusercontent.com/lbryio/reflector.go/master/config.tmpl && \
    chown -R 1000:1000 /data/config.tmpl

USER reflector

CMD ["start"]
