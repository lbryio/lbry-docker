#!/usr/bin/env bash

## Config setup

## Setup Values
DEBUGMODE=${DEBUGMODE:-false}
LBRYCRDURL="rpc://${RPC_USER:-lbryrpc}:${RPC_PASSWORD:-changeme}@10.5.1.2:9245"
MYSQLDSN="${MYSQL_USER:-changeme}:${MYSQL_PASSWORD:-changeme}@tcp(${MYSQL_SERVER:-10.5.1.10}:3306)/${MYSQL_DATABASE:-chainquery}"
APIMYSQLDSN="${MYSQL_USER:-changeme}:${MYSQL_PASSWORD:-changeme}@tcp(${MYSQL_SERVER:-10.5.1.10}:3306)/${MYSQL_DATABASE:-chainquery}"

## Setup Defaults
DEBUGMODE_DEFAULT='#DEFAULT-debugquerymode=false'
LBRYCRDURL_DEFAULT='#DEFAULT-lbrycrdurl="rpc://lbry:lbry@localhost:9245"'
MYSQLDSN_EFAULT='#DEFAULT-mysqldsn="lbry:lbry@tcp(localhost:3306)/chainquery"'
APIMYSQLDSN_DEFAULT='#DEFAULT-apihostport="0.0.0.0:6300"'

## Add setup value variable name to this list to get processed on container start
CONFIG_SETTINGS=(
  DEBUGMODE
  LBRYCRDURL
  MYSQLDSN_
  APIMYSQLDSN
)

function set_configs() {
  ## Set configs on container start if not already set.
  for i in "${!CONFIG_SETTINGS[@]}"; do
    ## Indirect references http://tldp.org/LDP/abs/html/ivr.html
    eval FROM_STRING=\$"${CONFIG_SETTINGS[$i]}_DEFAULT"
    eval TO_STRING=\$${CONFIG_SETTINGS[$i]}
    ## TODO: Add a bit more magic to make sure that you're only configuring things if not set by config mounts.
    sed -i '' "s~$FROM_STRING~$TO_STRING~g" /etc/chainquery/chainqueryconfig.toml
  done
}

if [[ ! -f /etc/chainquery/chainqueryconfig.toml ]]; then
  echo "[INFO]: Found no chainqueryconfig.toml"
  echo "        Installing default and configuring with provided environment variables if any."
  ## Install fresh copy of config file.
  cp /etc/chainquery/chainqueryconfig.toml.orig /etc/chainquery/chainqueryconfig.toml
  set_configs
else
  echo "[INFO]: Found a copy of chainqueryconfig.toml in /etc/chainquery"
  echo "        Attempting to non destructively install any new environment configurations."
  set_configs
fi

## For now keeping this simple. Potentially eventually add all command args as envvars for the Dockerfile or use safe way to add args via docker-compose.yml
su -c "chainquery serve -c "/etc/chainquery/"" chainquery
