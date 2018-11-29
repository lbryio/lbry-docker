#!/usr/bin/env bash
## Scope: This start.sh script will asssert container filesystem permissions and
## then execute the desired run mode for lbrynet with reduced permissions.
## The other thing this should do is simply create, configure or simply establish
## a fresh config with envvars passed to the container.

## Ensure perms are correct prior to running main binary
mkdir -p /lbrynet
chown -R lbrynet:lbrynet /lbrynet
chmod -R 755 /lbrynet

## TODO: Consider a config directory for future magic.
# chown -R 1000:1000 /etc/lbrynet
# chmod -R 755 /etc/lbrynet
# rm -f /var/run/lbrynet.pid

su -c "lbrynet start" lbrynet