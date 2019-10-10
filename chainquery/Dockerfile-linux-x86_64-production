## Get the latest source and extract it for the app container.
## Design choices, two RUN layers intended to keep builds faster, the zipped
FROM ubuntu:18.04 as prep
LABEL MAINTAINER="leopere [at] nixc [dot] us"
RUN apt-get update && \
  apt-get -y install unzip curl busybox-static && \
  apt-get autoclean -y && \
  rm -rf /var/lib/apt/lists/*
WORKDIR /
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY ./stuff/start.sh start
COPY ./stuff/healthcheck.sh healthcheck
RUN curl --progress-bar -L -o /chainquery https://build.lbry.io/chainquery/branch-master/chainquery && \
    chmod +x /chainquery /start /healthcheck

FROM ubuntu:18.04 as app
ADD https://raw.githubusercontent.com/lbryio/chainquery/master/config/default/chainqueryconfig.toml /etc/lbry/chainqueryconfig.toml.orig
RUN adduser chainquery --gecos GECOS --shell /bin/bash --disabled-password --home /home/chainquery && \
  chown -R chainquery:chainquery /etc/lbry
COPY --from=prep ./healthcheck /chainquery /start /bin/busybox /usr/bin/
HEALTHCHECK --interval=1m --timeout=30s \
  CMD healthcheck
EXPOSE 6300
USER chainquery
STOPSIGNAL SIGINT
CMD ["start"]
