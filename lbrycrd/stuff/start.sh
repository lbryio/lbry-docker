#!/usr/bin/env bash

# ## ToDo: Get a test case to see if this is the first run or a repeat run.
# ## If it's a first run you need to do a full index including all transactions
# ## tx index creates an index of every single transaction in the block history if
# ## not specified it will only create an index for transactions that are related to the wallet or have unspent outputs.
# ## This is specific to chainquery.

# The config file does not exist in the container image. It must be mounted, or
# if not, a default config is generated using environment variables.
CONFIG_PATH=/etc/lbry/lbrycrd.conf
if [ -f "$CONFIG_PATH" ]
then
    echo "Using the config file that was mounted into the container."
else
    echo "Creating a fresh config file from environment variables."
    ## Set config params
    mkdir -p `dirname $CONFIG_PATH`
    echo "rpcuser=$RPC_USER" > $CONFIG_PATH
    echo "rpcpassword=$RPC_PASSWORD" >> $CONFIG_PATH
    echo "rpcallowip=$RPC_ALLOW_IP" >> $CONFIG_PATH
    echo "rpcport=9245" >> $CONFIG_PATH
    echo "rpcbind=0.0.0.0" >> $CONFIG_PATH
    #echo "bind=0.0.0.0" >> $CONFIG_PATH
fi

## Ensure perms are correct prior to running main binary
/usr/bin/fix-permissions

## Control this invocation through envvar.
case $RUN_MODE in
  default )
    lbrycrdd -server -conf=$CONFIG_PATH -printtoconsole
    ;;
  reindex )
    lbrycrdd -server -txindex -reindex -conf=$CONFIG_PATH -printtoconsole
    ;;
  chainquery )
    lbrycrdd -server -txindex -conf=$CONFIG_PATH -printtoconsole
    ;;
esac
