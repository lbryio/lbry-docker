## This base image is for running latest chainquery
FROM ubuntu:18.04 as prep
LABEL MAINTAINER="leopere [at] nixc [dot] us"

## Install everything needed to unzip the file containing Chainquery
RUN apt-get update && \
    apt-get -y install unzip curl && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /download

## Download and extract the latest Zip containing Linux binary for Chainquery.
RUN curl -L -o /download/chainquery.zip $(curl -s https://api.github.com/repos/lbryio/chainquery/releases | fgrep 'Linux_x86_64.zip' | grep download | head -n 1 | cut -d'"' -f4) && \
    cd /download && \
    ls -lAh /download && pwd && \
    unzip chainquery.zip && \
    rm chainquery.zip

## TODO: Use this instead of everything above here at some point. To do this we will need the LBRY team to host all of their release binaries in their latest form internally I guess since github doesn't support latest tags.
# ADD --chown=1000:1000 https://github.com/lbryio/chainquery/releases/download/latest/chainquery_latest_Linux_x86_64.zip /download


# TODO: Switch to Alpine eventually we might need to compile in Alpine for this.
FROM ubuntu:18.04 as app

## Run as unprivileged user.
RUN adduser chainquery --gecos GECOS --shell /bin/bash --disabled-password --home /home/chainquery

# Pull chainquery executable from prep container.
COPY --from=0 /download/chainquery /usr/bin

# ADD --chown=1000:1000 https://github.com/lbryio/chainquery/releases/download/latest/chainquery_latest_Linux_x86_64.zip /usr/bin
# COPY stuff/chainqueryconfig.toml /etc/chainquery/

## Get latest chainqueryconfig.toml from master on github as template.
# TODO: add magic which pattern matches for chainqueryconfig.toml DEFAULT strings and replaces them with configured settings on container start.
ADD https://raw.githubusercontent.com/lbryio/chainquery/master/config/default/chainqueryconfig.toml /etc/chainquery/chainqueryconfig.toml.orig

## Install start.sh as executable script in container $PATH
COPY stuff/start.sh /usr/local/bin/start

# TODO: Implement docker-entrypoint if later required this might be handy if we need certain maintainence tasks to be executed in the live container.
# COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

# ## From here onward we're doing this with no root.
# USER chainquery

## Expose Chainquery API port
EXPOSE 6300

## Execute start script earlier installed into $PATH
CMD ["start"]
