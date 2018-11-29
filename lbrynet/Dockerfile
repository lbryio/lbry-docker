## This base image is for running the latest lbrynet-daemon release.
FROM ubuntu:18.04
LABEL MAINTAINER="leopere [at] nixc [dot] us"

RUN apt-get update && apt-get -y install unzip
# RUN mkdir -pv /lbrynet && chown 1000:1000 /lbrynet
RUN adduser lbrynet --gecos GECOS --shell /bin/bash/ --disabled-password --home /lbrynet/

## Add lbrynet
ADD https://lbry.io/get/lbrynet.linux.zip /lbrynet/lbrynet.linux.zip
RUN unzip /lbrynet/lbrynet.linux.zip -d /lbrynet/ && \
    rm /lbrynet/lbrynet.linux.zip && \
    chown -Rv traefik:lbrynet /lbrynet

RUN wget -quiet -O /usr/bin/debugpaste https://github.com/nixc-us/debugpaste-it/raw/master/bin/debugpaste_64 && \
    chmod +x /usr/bin/debugpaste

## Install into PATH
RUN mv /lbrynet/lbrynet-* /bin/

## Daemon port [Intended for internal use]
EXPOSE 4444
## LBRYNET talks to peers on port 3333 [Intended for external use] this port is used to discover other lbrynet daemons with blobs.
EXPOSE 3333


## ToDo: Determine why this port isn't documented in the lbry.tech resources for daemon-settings
# ## Wallet port [Intended for internal use]
# EXPOSE 50001
## All ports that are listed in the networking section of lbry.tech/resources/daemon-settings
# 3333 5566 4444 5279

## TODO: Highly Important, look over this and switch to managing a YAML config https://lbry.tech/resources/daemon-settings


## Volumize the wallets in a separate location for backup purposes may be unnecessary.
# VOLUME /lbrynet/.local/share/lbry/lbryum/wallets
# VOLUME /lbrynet/.local/

## Example daemon_settings.yml is at https://github.com/lbryio/lbry/blob/master/example_daemon_settings.yml
# VOLUME /etc/lbry/daemon_settings.yml

## Downloaded blobs will be in their own separate volume for keeping backups of critical secrets and data separate from backups of potentially massive blob files.
# VOLUME /lbrynet/Downloads/

## ToDo: replace lbrynet direct execution with start.sh function for enforcing directory perms on container launch.

## Never run container processes as root
USER lbrynet

## TODO: Add start.sh script which can assert permissions and do any configuration prep that's required on container start.
## Run on container launch
CMD ["lbrynet", "start"]
