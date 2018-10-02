#!/bin/bash

## Ensure perms are correct prior to running main binary
mkdir -p /data/lbrycrdd
chown -R 1000:1000 /data
chmod -R 755 /data
chown -R 1000:1000 /etc/lbrycrdd
chmod -R 755 /etc/lbrycrdd
rm -f /var/run/lbrycrdd.pid

## For now keeping this simple. Potentially eventually add all command args as envvars for the Dockerfile or use safe way to add args via docker-compose.yml
lbrycrdd \
  -conf=${CONF_PATH:-/etc/lbrycrdd/lbrycrdd.conf} \
  -data=${DATA_DIR:-/data/} \
  -port=${PORT:-9246} \
  -pid=${PID_FILE:/var/run/lbrycrdd.pid} \
  -printtoconsole \
  -rpcport=${RPC_PORT:-9245} \
  -rpcpassword=${RPC_PASSWORD:-changeme} \
  -rpcallowip=${RPC_ALLOW_IP:-10.10.0.2} \
  -rpcuser=${RPC_USER:-lbryrpc}
