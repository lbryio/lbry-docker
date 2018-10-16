## This base image is for running latest chainquery
FROM ubuntu:18.04 as prep
LABEL MAINTAINER="leopere [at] nixc [dot] us"

RUN apt-get update && \
    apt-get -y install unzip && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*

ADD --chown=1000:1000 https://github.com/lbryio/chainquery/releases/download/v1.1.2/chainquery_1.1.2_Linux_x86_64.zip /download
RUN cd /download/ && \
    unzip chainquery_1.1.2_Linux_x86_64.zip && \
    rm chainquery_1.1.2_Linux_x86_64.zip


## Switch to Alpine eventually we might need to compile in Alpine for this.
FROM ubuntu:18.04 as app

RUN adduser chainquery --gecos GECOS --shell /bin/bash --disabled-password --home /home/chainquery

COPY chainqueryconfig.toml /data/chainqueryconfig.toml
COPY start.sh /usr/local/bin/start
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

USER chainquery

## Expose Chainquery API port
EXPOSE 6300

CMD ["start"]
