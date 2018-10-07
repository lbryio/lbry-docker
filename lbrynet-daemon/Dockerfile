## This base image is for running the latest lbrynet-daemon release.
FROM ubuntu:18.04
MAINTAINER chamunks [at] gmail [dot] com

RUN apt-get update && apt-get -y install unzip
# RUN mkdir -pv /data && chown 1000:1000 /data
RUN adduser lbrynet --gecos GECOS --shell /bin/bash/ --disabled-password --home /data/

## Add lbrynet
ADD https://lbry.io/get/lbrynet.linux.zip /data/lbrynet.linux.zip
RUN unzip /data/lbrynet.linux.zip -d /data/ && \
    rm /data/lbrynet.linux.zip && \
    chown -Rv lbrynet:lbrynet /data

RUN wget -quiet -O /usr/bin/debugpaste https://github.com/nixc-us/debugpaste-it/raw/master/bin/debugpaste_64 && \
    chmod +x /usr/bin/debugpaste

## Install into PATH
RUN mv /data/lbrynet-* /bin/

ADD debugpaste-it.sh /usr/local/bin/debugpaste-it

## Daemon port [Intended for internal use]
EXPOSE 4444
## Wallet port [Intended for internal use]
EXPOSE 50001

## Undocumented ports that exist in conf.py
## API port
# EXPOSE 5279
# ## Reflector port
# EXPOSE 5566

## VOLUMES
## Right now the volumes are just added in a commented out state but if the end
## user would prefer to add volumes to their own usage cases all they will need
## to do is uncomment what they require and then build the container using docker-compose.yml

## Volumize the wallets in a separate location for backup purposes may be unnecessary.
# VOLUME /data/.local/share/lbry/lbryum/wallets
# VOLUME /data/.local/
## If the config ends up needing it's own volume it should be located here.
# VOLUME /etc/lbry/conf.py
## Downloaded blobs will be in their own separate volume for keeping backups of critical secrets and data separate from backups of potentially massive blob files.
# VOLUME /data/Downloads/

## Never run container processes as root
USER lbrynet
## Run on container launch
CMD ["lbrynet-daemon"]

## Setting this entrypoint should mean that you can `docker exec lbrynet commands`
## and you should be able to control the daemon's CLI this way.  There is an
## alternative method we could use here where we have an entrypoint shell script which could be a bit smarter.
## An docker-entrypoint should eventually be created and installed into the container $PATH with a config install script that checks for the existance of a config.py and if it exists don't install docker envvars established elsewhere.
## If the container doesn't detect a conf.py file however have it install a fresh copy into /etc/lbry/conf.py and run that from a fresh copy from somewhere sensible.
# ENTRYPOINT ["lbrynet-cli"]
