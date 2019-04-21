## This base image is for running latest lbrycrdd
# For some reason I may switch this image over to Alpine when I can RCA why it won't start.
FROM ubuntu:18.04
LABEL MAINTAINER="leopere [at] nixc [dot] us"

RUN addgroup --gid 1000 lbrycrd && \
    adduser lbrycrd --uid 1000 --gid 1000 --gecos GECOS --shell /bin/bash --disabled-password --home /data && \
    apt-get update && \
    apt-get -y install unzip wget curl && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*

## TODO: Consider adding debugpaste or variant
# RUN wget -O /usr/bin/debugpaste https://github.com/nixc-us/debugpaste-it/raw/master/bin/debugpaste_64 && \
#     chmod +x /usr/bin/debugpaste

RUN wget -O /usr/bin/lbrycrd-linux.zip https://github.com/lbryio/lbrycrd/releases/download/v0.12.4.0/lbrycrd-linux.zip && \
    cd /usr/bin/ && \
    unzip lbrycrd-linux.zip && \
    rm lbrycrd-linux.zip && \
    chmod +x lbrycrdd lbrycrd-cli lbrycrd-tx

COPY start.sh /usr/local/bin/start
COPY advance_blocks.sh /usr/local/bin/advance
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

# USER lbrycrd
# RUN mkdir /data
VOLUME ["/data"]
WORKDIR /data

## Exposing daemon port and RPC port
EXPOSE 9245 9246

## TODO: Decide what's important for lbrycrd and possibly add an entrypoint.
## Maybe catch things that might match things that can be easily executed in the
## lbrycrd cli and if nothing is entered just default to the containers shell.
## For now this is a placeholder that executes /bin/bash on `docker exec`
# ENTRYPOINT ["docker-entrypoint"]

CMD ["start"]
