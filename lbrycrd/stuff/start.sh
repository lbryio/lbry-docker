#!/usr/bin/env bash

# ## ToDo: Get a test case to see if this is the first run or a repeat run.
# ## If it's a first run you need to do a full index including all transactions
# ## tx index creates an index of every single transaction in the block history if
# ## not specified it will only create an index for transactions that are related to the wallet or have unspent outputs.
# ## This is specific to chainquery.

## Ensure perms are correct prior to running main binary
mkdir -p /data/.lbrycrd
chown -R lbrycrd:lbrycrd /data
chmod -R 755 /data/

## TODO: Consider a config directory for future magic.
# chown -R 1000:1000 /etc/lbrycrd
# chmod -R 755 /etc/lbrycrd
rm -f /var/run/lbrycrd.pid


## Set config params
## TODO: Make this more automagic in the future.
echo "rpcuser=lbryrpc\nrpcpassword=${RPC_PASSWORD:-changeme}" > /data/.lbrycrd/lbrycrd.conf
echo "rpcallowip=${RPC_ALLOW_IP:-10.5.1.3}" >> /data/.lbrycrd/lbrycrd.conf
echo "rpcuser=${RPC_USER:-lbryrpc}" >> /data/.lbrycrd/lbrycrd.conf

## Control this invocation through envvar.
case ${RUN_MODE:-default} in
  default )
    su -c "lbrycrdd -server -conf=/data/.lbrycrd/ -printtoconsole" lbrycrd
    ;;
  reindex )
    su -c "lbrycrdd -server -txindex -reindex -conf=/data/.lbrycrd/ -printtoconsole" lbrycrd
    ;;
  chainquery )
    su -c "lbrycrdd -server -txindex -conf=/data/.lbrycrd/ -printtoconsole" lbrycrd
    ;;
esac

## TODO: Look into what we can do with these launch params
## We were unsure if these function as intended so they were disabled for the time being.
#  -port=${PORT:-9246} \
#  -data=${DATA_DIR:-/data/} \
#  -pid=${PID_FILE:/var/run/lbrycrdd.pid} \
#  -rpcport=${RPC_PORT:-9245} \
#  -rpcpassword=${RPC_PASSWORD:-changeme} \
#  -rpcuser=${RPC_USER:-lbryrpc} \
#  -rpcallowip=${RPC_ALLOW_IP:-10.5.1.3}
