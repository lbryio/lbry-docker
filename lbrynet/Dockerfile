## This base image is for running the latest lbrynet-daemon release.
FROM ubuntu:18.04
LABEL MAINTAINER="leopere [at] nixc [dot] us"

RUN apt-get update && apt-get -y install unzip
RUN adduser lbrynet --gecos GECOS --shell /bin/bash --disabled-password --home /lbrynet/

## Add lbrynet
ADD https://lbry.io/get/lbrynet.linux.zip /lbrynet/lbrynet.linux.zip
RUN unzip /lbrynet/lbrynet.linux.zip -d /lbrynet/ && \
    rm /lbrynet/lbrynet.linux.zip && \
    chown -Rv lbrynet:lbrynet /lbrynet && \
    mv /lbrynet/lbrynet /bin/
    
# COPY stuff/debugpaste-it.sh /usr/local/bin/debugpaste-it
COPY stuff/start.sh /usr/local/bin/start
COPY stuff/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY stuff/healthcheck.sh /usr/local/bin/healthcheck

## Daemon port [Intended for internal use]
## LBRYNET talks to peers on port 3333 [Intended for external use] this port is used to discover other lbrynet daemons with blobs.
## Expose 5566 Reflector port to listen on
## Expose 5279 Port the daemon API will listen on
## the lbryumx aka Wallet port [Intended for internal use]
EXPOSE 4444 3333 5566 5279 50001



## TODO: Have wallets stored on their own volume/subdirectory for security, and backups.
## Volumize the wallets in a separate location for backup purposes may be unnecessary.
# VOLUME /lbrynet/.local/share/lbry/lbryum/wallets
# VOLUME /lbrynet/.local/

## Example daemon_settings.yml is at https://github.com/lbryio/lbry/blob/master/example_daemon_settings.yml
ADD https://raw.githubusercontent.com/lbryio/lbry/master/example_daemon_settings.yml /etc/lbrynet/example_daemon_settings.yml
## TODO: In start.sh detect and merge changes.
# VOLUME /etc/lbry/daemon_settings.yml

## TODO: Downloaded blobs will be in their own separate volume for keeping backups of critical secrets and data separate from backups of potentially massive blob files.
# VOLUME /lbrynet/Downloads/

ENTRYPOINT ["/bin/bash"]

CMD ["start"]
