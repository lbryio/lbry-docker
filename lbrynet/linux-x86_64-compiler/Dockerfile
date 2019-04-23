FROM ubuntu:18.04 as dependencies
RUN apt-get update && \
    apt-get install -y \
      python3-pip \
      python3.7 \
      python3.7-dev \
      build-essential \
      libssl-dev \
      libacl1-dev \
      liblz4-dev \
      libfuse-dev \
      fuse \
      pkg-config \
      fakeroot \
      git \
      zlib1g-dev \
      libbz2-dev \
      libncurses5-dev \
      libreadline-dev \
      liblzma-dev \
      libsqlite3-dev \
      zip \
      libffi-dev \
      libleveldb-dev && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.7 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.7 10 && \
    update-alternatives --config python && \
    python --version && \
    pip3 --version

FROM dependencies as compile

RUN python3.7 -m pip install -U pyinstaller && \
    git clone https://github.com/lbryio/lbry.git --depth 1 /lbry && \
    cd /lbry && \
    git clone https://github.com/lbryio/torba.git --depth 1 /lbry/torba && \
    cd /lbry/torba && python3.7 -m pip install -e . && \
    cd /lbry/ && python3.7 scripts/set_build.py && \
    python3.7 -m pip install -e . && \
    pyinstaller -F -n lbrynet lbrynet/extras/cli.py && \
    chmod +x /lbry/dist/lbrynet && \
    zip -j /lbry/dist/lbrynet-armhf.zip /lbry/dist/lbrynet && \
    mkdir /target && \
    /lbry/dist/lbrynet --version

FROM ubuntu:18.04 as app
RUN adduser lbrynet --gecos GECOS --shell /bin/bash --disabled-password --home /home/lbrynet
COPY start.sh /usr/local/bin/start
COPY --from=compile /lbry/dist/lbrynet /usr/local/bin/
EXPOSE 5279
USER lbrynet
CMD ["start"]
