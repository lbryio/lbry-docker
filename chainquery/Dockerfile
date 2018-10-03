## This base image is for running latest chainquery
FROM ubuntu:18.04
MAINTAINER chamunks [at] gmail [dot] com

ADD chainqueryconfig.toml /data/chainqueryconfig.toml
ADD start.sh /usr/local/bin/start
ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN adduser chainquery --gecos GECOS --shell /bin/bash --disabled-password --home /data/ && \
    apt-get update && \
    apt-get -y install unzip wget && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/bin/chainquery.zip https://github.com/lbryio/chainquery/releases/download/v1.1.2/chainquery_1.1.2_Linux_x86_64.zip && \
    cd /usr/bin/ && \
    unzip chainquery.zip && \
    rm chainquery.zip && \
    chown -R 1000:1000 /data && \
    chmod -R 755 /data

USER chainquery

## Expose Chainquery API port
EXPOSE 6300 3306

CMD ["start"]
