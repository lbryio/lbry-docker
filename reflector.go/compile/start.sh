#!/bin/bash

## Launch service will tell prism-bin what mode to run in.
LAUNCHMODE="${MODE:-$1}"

## This variable will be what can override default launch args.  I may modify this as I learn more about prism-bin
LAUNCHARGS="${CUSTOM_ARGS:-$2}"

## This is setup this way to handle any situations that might arise from the
## config being JSON and bash not being any good at JSON.
# ## Strings to replace.
AWS_ID_STR="YOUR-AWS-ID"
AWS_SECRET_STR="YOUR-AWS-SECRET"
BUCKET_REGION_STR="YOUR-BUCKET-REGION"
BUCKET_NAME_STR="YOUR-BUCKET-NAME"
DB_USER_STR="USER"
DB_PASSWORD_STR="PASSWORD"
DB_HOSTIP_STR="localhost"
DB_PORT_STR="3306"
DB_NAME_STR="DBNAME"

## For the most part this section is disabled
# ## Keys to re-insert
# AWS_ID_KEY=''
# AWS_SECRET_KEY=''
# BUCKET_REGION_KEY=''
# BUCKET_NAME_KEY=''
# DB_USER_KEY=''
# DB_PASSWORD_KEY=''
# DB_HOSTIP_KEY=''
# DB_PORT_KEY=''
# DB_NAME_KEY=''

# Environment Variables/Defaults
## Json sucks in BASH/Shell so you need to add trailing commas intermittently.
## Just pay attention to this.  Also at some point I'll need to make a fringe
## case for handling key/values that aren't included in the default config.
AWS_ID="${AWS_ID:-potato}"
AWS_SECRET="${AWS_SECRET:-potato}"
BUCKET_REGION="${BUCKET_REGION:-potato}"
BUCKET_NAME="${BUCKET_NAME:-potato}"
DB_USER="${DB_USER:-potato}"
DB_PASSWORD="${DB_PASSWORD:-potato}"
DB_HOSTIP="${DB_HOSTIP:-potato}"
DB_PORT="${DB_PORT:-potato}"
DB_NAME="${DB_NAME:-potato}"

## Environment Variables
## Missing Vars off the hop SLACK_HOOK_URL
CONFIG_SETTINGS=(
  AWS_ID
  AWS_SECRET
  BUCKET_REGION
  BUCKET_NAME
  DB_USER
  DB_PASSWORD
  DB_HOSTIP
  DB_PORT
  DB_NAME
)
CONFIG_SECRETS=(
  AWS_ID
  AWS_ID_STR
  AWS_SECRET
  AWS_SECRET_STR
  BUCKET_NAME
  BUCKET_NAME_STR
  DB_USER
  DB_USER_STR
  DB_PASSWORD
  DB_PASSWORD_STR
  DB_HOSTIP
  DB_HOSTIP_STR
  DB_PORT
  DB_PORT_STR
  DB_NAME
  DB_NAME_STR
)

## This function might be a bit overkill as all key/value pairs are unique in this config.
for i in "${!CONFIG_SETTINGS[@]}"; do
  echo ${CONFIG_SETTINGS[$i]}"_KEY"
  ## Indirect references http://tldp.org/LDP/abs/html/ivr.html
  eval FROM_STRING=\$"${CONFIG_SETTINGS[$i]}_STR"
  eval VALUE_STRING=\$${CONFIG_SETTINGS[$i]}
  eval KEY_STRING=\$"${CONFIG_SETTINGS[$i]}_KEY"
  TO_STRING="$KEY_STRING$VALUE_STRING"
  ## DEBUG
  # echo DEBUG FROM_STRING: "$FROM_STRING"
  # echo DEBUG VALUE_STRING: $VALUE_STRING
  # echo DEBUG KEY_STRING: $KEY_STRING
  # echo DEBUG TO_STRING: "$TO_STRING"
  sed -i '' "s/$FROM_STRING/$TO_STRING/g" ./config.tmpl
done

## Sanitization section
# Awaiting someone smarter than me to suggest a method for this.
# https://unix.stackexchange.com/questions/474097/i-want-to-unset-a-list-of-bash-variables-that-have-their-variable-strings-stored
for i in "${CONFIG_SECRETS[@]}"; do
  unset $i
done

# Actual launch invoked here
case $MODE in
  cluster )
    prism-bin cluster ${LAUNCHARGS:-'-v --conf /data/config.tmpl'}
    ;;
  dht )
    ## Env vars NODEID DHTPORT
    ## Figure out what port we want to run --rpcPort on by default
    ## Figure out if we need seed strings and set default(s)
    prism-bin dht ${LAUNCHARGS:-'-v --conf /data/config.tmpl --nodeID $NODEID --port "${DHTPORT:-4567}"'}
    ;;
  peer )
    prism-bin peer ${LAUNCHARGS:-'-v --conf /data/config.tmpl'}
    ;;
  reflector )
    prism-bin reflector ${LAUNCHARGS:-'-v --conf /data/config.tmpl'}
    ;;
esac
