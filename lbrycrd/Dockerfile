## This base image is for running latest lbrycrdd
# For some reason I may switch this image over to Alpine when I can RCA why it won't start.
FROM ubuntu:18.04
MAINTAINER chamunks [at] gmail [dot] com

RUN adduser lbrycrdd --gecos GECOS --shell /bin/bash/ --disabled-password --home /data/ && \
    apt-get update && \
    apt-get -y install unzip wget && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*


RUN wget -O /usr/bin/lbrycrd-linux.zip https://github.com/lbryio/lbrycrd/releases/download/v0.12.2.2/lbrycrd-linux.zip && \
    cd /usr/bin/ && \
    unzip lbrycrd-linux.zip && \
    rm lbrycrd-linux.zip

ADD start.sh /usr/local/bin/start
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint

USER lbrycrdd

VOLUME /data/
VOLUME /etc/lbrycrdd/

## Exposing daemon port and RPC port
EXPOSE 9245 9246

## For now this is a placeholder that executes /bin/bash on `docker exec`
ENTRYPOINT ["docker-entrypoint"]

CMD ["start"]
