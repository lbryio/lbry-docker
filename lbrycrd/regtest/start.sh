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
echo "rpcuser=lbry" >           /data/.lbrycrd/lbrycrd.conf
echo "rpcpassword=lbry" >>      /data/.lbrycrd/lbrycrd.conf
echo "rpcport=11337" >>         /data/.lbrycrd/lbrycrd.conf
echo "rpcbind=0.0.0.0" >>       /data/.lbrycrd/lbrycrd.conf
echo "rpcallowip=0.0.0.0/0" >>  /data/.lbrycrd/lbrycrd.conf
echo "regtest=1" >>             /data/.lbrycrd/lbrycrd.conf
echo "txindex=1" >>             /data/.lbrycrd/lbrycrd.conf
echo "server=1" >>              /data/.lbrycrd/lbrycrd.conf
echo "printtoconsole=1" >>      /data/.lbrycrd/lbrycrd.conf

#nohup advance &>/dev/null &
su -c "lbrycrdd -conf=/data/.lbrycrd/lbrycrd.conf" lbrycrd

