#!/bin/bash
#!/bin/sh

## Launch service will tell prism-bin what mode to run in.
LAUNCHMODE="${MODE:-$1}"

## This variable will be what can override default launch args.  I may modify this as I learn more about prism-bin
LAUNCHARGS="${CUSTOM_ARGS:-$2}"

# ## Strings to replace.
AWS_ID_STR='YOUR-AWS-ID'
AWS_SECRET_STR=''
BUCKET_REGION_STR=''
BUCKET_NAME_STR=''
DB_USER_STR=''
DB_PASSWORD=''
DB_HOSTIP=''
DB_PORT=''
DB_NAME=''

# ## Keys to re-insert
AWS_ID_KEY=''
AWS_SECRET_KEY=''
BUCKET_REGION_KEY=''
BUCKET_NAME_KEY=''
DB_USER_KEY=''
DB_PASSWORD=''
DB_HOSTIP=''
DB_PORT=''
DB_NAME=''

# Environment Variables/Defaults
## Json sucks in BASH/Shell so you need to add trailing commas intermittently.
## Just pay attention to this.  Also at some point I'll need to make a fringe
## case for handling key/values that aren't included in the default config.
AWS_ID="${AWS_ID:-YOUR-AWS-ID}"
AWS_SECRET="${AWS_SECRET:-YOUR_AWS_SECRET}"
BUCKET_REGION="${BUCKET_REGION:-YOUR_BUCKET_REGION}"
BUCKET_NAME="${BUCKET_NAME:-YOUR_BUCKET_NAME}"
DB_USER="${DB_USER:-DB_USER}"
DB_PASSWORD="${DB_PASSWORD:-YOUR_DB_PASSWORD}"
DB_HOSTIP="${DB_HOSTIP:-YOUR_DB_HOSTIP}"
DB_PORT="${DB_PORT:-YOUR_DB_PORT}"
DB_NAME="${DB_NAME:-YOUR_DB_NAME}"

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

## This function might be a bit overkill as all key/value pairs are unique in this config.
function config_modify() {
  for i in "${!CONFIG_SETTINGS[@]}"; do
    # echo ${CONFIG_SETTINGS[$i]}"_KEY"
    ## Indirect references http://tldp.org/LDP/abs/html/ivr.html
    eval FROM_STRING=\$"${CONFIG_SETTINGS[$i]}_STR"
    eval VALUE_STRING=\$${CONFIG_SETTINGS[$i]}
    eval KEY_STRING=\$"${CONFIG_SETTINGS[$i]}_KEY"
    TO_STRING="$KEY_STRING $VALUE_STRING"
    ## DEBUG
    # echo DEBUG FROM_STRING: "$FROM_STRING"
    # echo DEBUG VALUE_STRING: $VALUE_STRING
    # echo DEBUG KEY_STRING: $KEY_STRING
    # echo DEBUG TO_STRING: "$TO_STRING"
    sed -i "s/$FROM_STRING/${TO_STRING:-$FROM_STRING}/g" /data/config.tmpl
  done
}
config_modify

## Actual launch invoked here
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
