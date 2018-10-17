###########################
## Compiler/Builder Step ##
###########################
FROM ubuntu:18.04 as builder
LABEL MAINTAINER="@Brannon Update Me Or Put Mine Here"

## Added apt work as single container layer then remove cruft before layer is committed.
RUN apt-get update && \
    apt-get install -y build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 git wget apt-utils && \
    apt-get install -y libssl-dev libevent-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-test-dev libboost-thread-dev libboost-locale-dev libboost-program-options-dev && \
    apt-get install -y python-dev libbz2-dev autoconf ca-certificates clang-format && \
    apt-get install -y software-properties-common && add-apt-repository -y ppa:bitcoin/bitcoin && apt-get update && apt-get install -y libdb4.8-dev libdb4.8++-dev && \
    apt-get -y install unzip wget && \ ## Cleanup Post apt package installation.
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* ## Others neednt play here(remove apt lists as no longer needed at this stage).

## Add debugpaste here for reporting compiler errors.  Psuedo code.
## RUN wget -O /usr/local/bin/debugpaste https://url && \
##     sha256sum check of debugpaste

########################
## Compile Steps Here ##
########################
## Compile and Test steps should likely be separate run commands/layers.
RUN ## Compile/Test steps here


####################
## App build step ##
####################
FROM ubuntu:18.04 as app

## Change this to pull from a certifiable source with supply chain in plain sight.
# RUN wget -O /usr/bin/debugpaste https://github.com/nixc-us/debugpaste-it/raw/master/bin/debugpaste_64 && \
#     chmod +x /usr/bin/debugpaste

RUN adduser lbrycrd --gecos GECOS --shell /bin/bash --disabled-password --home /app

# ## This section can be replaced with a COPY to pull artifacts from build step.
# # RUN wget -O /usr/bin/lbrycrd-linux.zip https://github.com/lbryio/lbrycrd/releases/download/v0.12.2.2/lbrycrd-linux.zip && \
# #     cd /usr/bin/ && \
# #     unzip lbrycrd-linux.zip && \
# #     rm lbrycrd-linux.zip && \
# #     chmod +x lbrycrdd lbrycrd-cli lbrycrd-tx
# COPY --chown=1000:1000 /path/to/compiled/lbrycrd/bins /app/

## This needn't be included until debugpaste is ready.
# COPY debugpaste-it.sh /usr/local/bin/debugpaste-it
# COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY start.sh /usr/local/bin/start


USER lbrycrdd

RUN mkdir -p /data/

VOLUME /data/
VOLUME /etc/lbrycrdd/

## Exposing daemon port and RPC port
EXPOSE 9245 9246

# ## For now this is a placeholder that executes /bin/bash on `docker exec`
# ENTRYPOINT ["docker-entrypoint"]

CMD ["start"]
