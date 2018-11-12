#!/usr/bin/env bash

## Config setup

## Setup Values
echo FINDME
DEBUGMODE=$(echo "debugquerymode=${DEBUGMODE:-false}")
echo $DEBUGMODE
LBRYCRDURL=$(echo "rpc://${RPC_USER:-lbryrpc}:${RPC_PASSWORD:-changeme}@10.5.1.2:9245")
echo $LBRYCRDURL
MYSQLDSN=$(echo "${MYSQL_USER:-chainquery}:${MYSQL_PASSWORD:-changeme}@tcp(${MYSQL_SERVER:-10.5.1.10}:3306)/${MYSQL_DATABASE:-chainquery}")
echo $MYSQLDSN
APIMYSQLDSN=$(echo "${MYSQL_USER:-chainquery}:${MYSQL_PASSWORD:-changeme}@tcp(${MYSQL_SERVER:-10.5.1.10}:3306)/${MYSQL_DATABASE:-chainquery}")
echo $APIMYSQLDSN

## Setup Defaults
DEBUGMODE_DEFAULT='#DEFAULT-debugquerymode=false'
LBRYCRDURL_DEFAULT='#DEFAULT-lbrycrdurl="rpc://lbry:lbry@localhost:9245"'
MYSQLDSN_DEFAULT='#DEFAULT-mysqldsn="lbry:lbry@tcp(localhost:3306)/chainquery"'
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
    sed -i "s~$FROM_STRING~"$TO_STRING"~g" /etc/chainquery/chainqueryconfig.toml
  done
  echo "Reading config for debugging."
  cat /etc/chainquery/chainqueryconfig.toml
}

if [[ ! -f /etc/chainquery/chainqueryconfig.toml ]]; then
  echo "[INFO]: Did not find chainqueryconfig.toml"
  echo "        Installing default and configuring with provided environment variables if any."
  ## Install fresh copy of config file.
  echo "cp -v /etc/chainquery/chainqueryconfig.toml.orig /etc/chainquery/chainqueryconfig.toml"
  cp -v /etc/chainquery/chainqueryconfig.toml.orig /etc/chainquery/chainqueryconfig.toml
  chmod 755 /etc/chainquery/chainqueryconfig.toml
  ls -lAh /etc/chainquery/
  set_configs
else
  echo "[INFO]: Found a copy of chainqueryconfig.toml in /etc/chainquery"
  echo "        Attempting to non destructively install any new environment configurations."
  set_configs
fi

## For now keeping this simple. Potentially eventually add all command args as envvars for the Dockerfile or use safe way to add args via docker-compose.yml
su -c "chainquery serve -c "/etc/chainquery/"" chainquery
