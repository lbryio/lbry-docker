## This base image is for running latest chainquery
FROM ubuntu:18.04 as prep
LABEL MAINTAINER="leopere [at] nixc [dot] us"

RUN apt-get update && \
    apt-get -y install unzip curl && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /download

RUN curl -L -o /download/chainquery.zip $(curl -s https://api.github.com/repos/lbryio/chainquery/releases | fgrep 'Linux_x86_64.zip' | grep download | head -n 1 | cut -d'"' -f4)

## I really want to use this instead of all the curl stuff at one point.
# ADD --chown=1000:1000 https://github.com/lbryio/chainquery/releases/download/latest/chainquery_latest_Linux_x86_64.zip /download
RUN cd /download && \
    ls -lAh /download && pwd && \
    unzip chainquery.zip && \
    rm chainquery.zip

## Switch to Alpine eventually we might need to compile in Alpine for this.
FROM ubuntu:18.04 as app

RUN adduser chainquery --gecos GECOS --shell /bin/bash --disabled-password --home /home/chainquery

COPY --from=0 /download/chainquery /usr/bin
COPY chainqueryconfig.toml /data/chainqueryconfig.toml
COPY start.sh /usr/local/bin/start
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

USER chainquery

## Expose Chainquery API port
EXPOSE 6300

CMD ["start"]
