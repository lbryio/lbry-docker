## Compiler for lbrynet container for any architecture supported by Ubuntu 18.04
## Specify the BASE_IMAGE build argument to choose which Ubuntu base image to build from.
## Docs for ARG in FROM:  https://github.com/docker/cli/blob/master/docs/reference/builder.md#understand-how-arg-and-from-interact
## Architecture | Build command
##    x86_64    | docker build -t lbrynet -f Dockerfile-compiler .
##    armhf     | docker build -t lbrynet-armhf -f Dockerfile-compiler --build-arg BASE_IMAGE=multiarch/ubuntu-core:armhf-bionic .
##    arm64     | docker build -t lbrynet-arm64 -f Dockerfile-compiler --build-arg BASE_IMAGE=multiarch/ubuntu-core:arm64-bionic .

ARG BASE_IMAGE=ubuntu:18.04
FROM ${BASE_IMAGE} as dependencies
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
    git clone https://github.com/lbryio/lbry.git --depth 1 /lbry
    WORKDIR /lbry
RUN git clone https://github.com/lbryio/torba.git --depth 1 /lbry/torba
WORKDIR /lbry/torba
RUN python3.7 -m pip install -e .
WORKDIR /lbry/
COPY stuff/start.sh /usr/local/bin/start
COPY stuff/checkmount.sh /usr/local/bin/checkmount
RUN python3.7 scripts/set_build.py && \
    python3.7 -m pip install -e . && \
    pyinstaller -F -n lbrynet lbrynet/extras/cli.py && \
    chmod +x /lbry/dist/lbrynet && \
    zip -j /lbry/dist/lbrynet-armhf.zip /lbry/dist/lbrynet && \
    chmod a+x /usr/local/bin/* && \
    mkdir /target && \
    /lbry/dist/lbrynet --version

FROM ${BASE_IMAGE} as app
RUN adduser lbrynet --gecos GECOS --shell /bin/bash --disabled-password --home /home/lbrynet
COPY --from=compile /usr/local/bin/start /usr/local/bin/checkmount /lbry/dist/lbrynet /usr/local/bin/
EXPOSE 5279
USER lbrynet
ENTRYPOINT ["/usr/local/bin/checkmount"]
CMD ["start"]
