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
echo "rpcuser=$RPC_USER" > /data/.lbrycrd/lbrycrd.conf
echo "rpcpassword=$RPC_PASSWORD" >> /data/.lbrycrd/lbrycrd.conf
echo "rpcallowip=$RPC_ALLOW_IP" >> /data/.lbrycrd/lbrycrd.conf
echo "rpcport=9245" >> /data/.lbrycrd/lbrycrd.conf
echo "rpcbind=0.0.0.0" >> /data/.lbrycrd/lbrycrd.conf
#echo "bind=0.0.0.0" >> /data/.lbrycrd/lbrycrd.conf

## Control this invocation through envvar.
case $RUN_MODE in
  default )
    su -c "lbrycrdd -server -conf=/data/.lbrycrd/lbrycrd.conf -printtoconsole" lbrycrd
    ;;
  reindex )
    su -c "lbrycrdd -server -txindex -reindex -conf=/data/.lbrycrd/lbrycrd.conf -printtoconsole" lbrycrd
    ;;
  chainquery )
    su -c "lbrycrdd -server -txindex -conf=/data/.lbrycrd/lbrycrd.conf -printtoconsole" lbrycrd
    ;;
esac
