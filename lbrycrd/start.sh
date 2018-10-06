#!/bin/bash
## ToDo:
## Get a test case to see if this is the first run or a repeat run
## If it's a first run you need to do a full index including all transactions
## tx index creates an index of every single transaction in the block history if
## not specified it will only create an index for transactions that are related to the wallet or have unspent outputs.
## This is specific to chainquery.

## Ensure perms are correct prior to running main binary
chown -R 1000:1000 /data
chmod -R 755 /data
chown -R 1000:1000 /etc/lbrycrdd
chmod -R 755 /etc/lbrycrdd
rm -f /var/run/lbrycrdd.pid

## For now keeping this simple. Potentially eventually add all command args as envvars for the Dockerfile or use safe way to add args via docker-compose.yml
## Command to initialize
# lbrycrdd \
#   -conf=${CONF_PATH:-/etc/lbrycrdd/lbrycrdd.conf} \
#   -data=${DATA_DIR:-/data/} \
#   -port=${PORT:-9246} \
#   -pid=${PID_FILE:/var/run/lbrycrdd.pid} \
#   -printtoconsole \
#   -rpcport=${RPC_PORT:-9245} \
#   -rpcpassword=${RPC_PASSWORD:-changeme} \
#   -rpcuser=${RPC_USER:-lbryrpc} \
#   -rpcallowip=${RPC_ALLOW_IP:-10.10.0.2} \
#   -reindex \
#   -txindex

## Command to run for long term.
lbrycrdd \
  -conf=${CONF_PATH:-/etc/lbrycrdd/lbrycrdd.conf} \
  -data=${DATA_DIR:-/data/} \
  -port=${PORT:-9246} \
  -pid=${PID_FILE:/var/run/lbrycrdd.pid} \
  -printtoconsole \
  -rpcport=${RPC_PORT:-9245} \
  -rpcpassword=${RPC_PASSWORD:-changeme} \
  -rpcuser=${RPC_USER:-lbryrpc} \
  -rpcallowip=${RPC_ALLOW_IP:-10.10.0.2} \
  -txindex
