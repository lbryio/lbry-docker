#!/bin/bash
set -eo pipefail
## Add -x to set if you want really explicit feedback.
## -u breaks unbound variables
## This docker-entrypoint will take a copy of the configuration and install any
## ENVVARS and then copy any required files into the /app/ directory next to any
## custom files added by the user.

# default to run whatever the user wanted like "/bin/ash"
## If user runs no need to run any more of the entrypoint script.
if [[ -z "$@" ]]; then
  echof info "User did not attempt input. Now executing docker-entrypoint."
else
  echof info "Running $@."
  exec "$@"
  exit 1
fi

ENVVARS=("MYSQL_ENV_MYSQL_USER"
  "MYSQL_ENV_MYSQL_PASSWORD"
  "MYSQL_ENV_MYSQL_DATABASE"
  "MYSQL_ENV_MYSQL_ADDRESS"
  "GOOGLE_ANALYTICS_UID"
  "SITE_TITLE"
  "SITE_ADDRESS"
  "SITE_DESCRIPTION"
)
# MYSQL_ENV_MYSQL_USER=alphauser
# MYSQL_ENV_MYSQL_PASSWORD=alphapassword
# MYSQL_ENV_MYSQL_DATABASE=alphadatabase
# MYSQL_ENV_MYSQL_ADDRESS=alphaaddress
# GOOGLE_ANALYTICS_UID=alphauid
# SITE_TITLE=AlphaTitle
# SITE_ADDRESS=alpha.address.com
SITE_DESCRIPTION=alpha.description

function set_conf() {
  case $1 in
    MYSQL_ENV_MYSQL_USER )
      if [[ -z "$MYSQL_ENV_MYSQL_USER" ]]; then
        echof info "User did not attempt to configure $MYSQL_ENV_MYSQL_USER"
      else
        echof info "Configuring $MYSQL_ENV_MYSQL_USER."
        echof info "Setting '$MYSQL_ENV_MYSQL_USER' $MYSQL_ENV_MYSQL_USER in /app/config/mysqlConfig.json"
        sed -i 's/"username": "root"/"username": "'$MYSQL_ENV_MYSQL_USER'"/' /app/config/mysqlConfig.json
      fi
    ;;
    MYSQL_ENV_MYSQL_PASSWORD )
      if [[ -z "$MYSQL_ENV_MYSQL_PASSWORD" ]]; then
        echof info "User did not attempt to configure $MYSQL_ENV_MYSQL_PASSWORD"
      else
        ## This echo should be sanitized of any secrets before this is finished.
        echof info "Setting '$MYSQL_ENV_MYSQL_PASSWORD' $MYSQL_ENV_MYSQL_PASSWORD in /app/config/mysqlConfig.json"
        sed -i 's/"password": ""/"password": "'$MYSQL_ENV_MYSQL_PASSWORD'"/' /app/config/mysqlConfig.json
      fi
      ;;
    MYSQL_ENV_MYSQL_DATABASE )
      if [[ -z "$MYSQL_ENV_MYSQL_DATABASE" ]]; then
        echof info "User did not attempt to configure $MYSQL_ENV_MYSQL_DATABASE"
      else
        echof info "Setting '$MYSQL_ENV_MYSQL_DATABASE' $MYSQL_ENV_MYSQL_DATABASE in /app/config/mysqlConfig.json"
        sed -i 's/"database": "lbry"/"database": "'$MYSQL_ENV_MYSQL_DATABASE'"/' /app/config/mysqlConfig.json
      fi
    ;;
    MYSQL_SERVER_ADDRESS )
      if [[ -z "$MYSQL_SERVER_ADDRESS" ]]; then
        echof info "User did not attempt to configure $MYSQL_SERVER_ADDRESS"
      else
        echof warn "This variable is not currently available."
      fi
    ;;
    SITE_ADDRESS )
      if [[ -z "$SITE_ADDRESS" ]]; then
        echof info "User did not attempt to configure $SITE_ADDRESS"
      else
        echof info "Setting '$SITE_ADDRESS' $SITE_ADDRESS in /app/config/siteConfig.json"
        sed -i 's,"host": "https://www.example.com","host": "https://"$SITE_ADDRESS,' /app/config/siteConfig.json
      fi
    ;;
    GOOGLE_ANALYTICS_UID )
      if [[ -z "$GOOGLE_ANALYTICS_UID" ]]; then
        echof info "User did not attempt to configure $GOOGLE_ANALYTICS_UID"
      else
        echof info "Setting '$GOOGLE_ANALYTICS_UID' $GOOGLE_ANALYTICS_UID in /app/config/siteConfig.json"
        sed -i 's/"googleId": null/"googleId": '$GOOGLE_ANALYTICS_UID'/' /app/config/siteConfig.json
      fi
    ;;
    SITE_TITLE )
      if [[ -z "$SITE_TITLE" ]]; then
        echof info "User did not attempt to configure $SITE_TITLE"
      else
        echof info "Setting '$SITE_TITLE' $SITE_TITLE in /app/config/siteConfig.json"
        sed -i 's/"title": "My Site"/"title": "'$SITE_TITLE'"/' /app/config/siteConfig.json
      fi
    ;;
    SITE_DESCRIPTION )
      if [[ -z "$SITE_DESCRIPTION" ]]; then
        echof info "User did not attempt to configure $SITE_DESCRIPTION"
      else
        echof info "Setting '$SITE_DESCRIPTION' $SITE_DESCRIPTION in /app/config/siteConfig.json"
        sed -i 's/"description": "A decentralized hosting platform built on LBRY"/"Description": "'$SITE_DESCRIPTION'"/' /app/config/siteConfig.json
      fi
    ;;
  esac
}

function configure_speech() {
  # install configuration changes here.
  echof info "Installing configuration files into /app/config/."
  mkdir -p /app/config/
  cp /usr/local/src/www.spee.ch/cli/defaults/mysqlConfig.json /app/config/mysqlConfig.json
  cp /usr/local/src/www.spee.ch/cli/defaults/siteConfig.json /app/config/siteConfig.json
  echof info "Installing any environment variables that have been set."
  for i in "${ENVVARS[@]}"; do
    if [[ -z "$i" ]]; then
      echof info "$i was not set, moving on."
    else
      set_conf $i
    fi
  done
}

function final_permset() {
  ## Finally reassert permissions in case there is user added drift.
  rddo /app "test_for_dir" '775 "speech:speech"'
  rfdo /app "test_for_file" '665 "speech:speech"'
  ## Define any permission exceptions here.
  # test_for_dir /app/config 775 "speech:speech"
  # test_for_file /app/config/siteConfig.json 665 "speech:speech"
  echof info "Copied Spee.ch and set permissions"
}

###################################
## Actual installation function. ##
###################################
# if Spee.ch is not yet installed, copy it into web root.
# This could be updated to be part of an upgrade mechanism.
if [ "$(ls -A /app)" ]; then
  echof warn "/app is not Empty. It contains:" 1>&2
  ls -A 1>&2
  ## If siteConfig.json isn't installed add it and configure or ignore and proceed.
  if [ ! -e '/app/config/siteConfig.json' ]; then
    echof warn "Spee.ch doesn't appear to have a configuration."
    echof blank "Installing config"
    configure_speech
  else
    ## If the file exists skip configuration and proceed.
    echof info "Spee.ch config already installed skipping configuration step."
    final_permset
  fi
  ## Install all other files after installing siteConfig.json
  echof info "Making an attempt to nicely merge files using:"
  echof run "mv -fnu /usr/local/src/www.spee.ch/* /app/"
  mv -fnu /usr/local/src/www.spee.ch/* /app/
  final_permset
else
  echof info "Speech not installed, installing fresh copy now."
  configure_speech
  echof run "cp -rv /usr/local/src/www.spee.ch/* /app/"
  cp -rv /usr/local/src/www.spee.ch/* /app/
  final_permset
fi

## Superfluous permissions assertion maybe axe this later.
echof run 'test_for_dir /app/config/siteConfig.json 775 "speech:speech"'
test_for_file /app/config/siteConfig.json 775 "speech:speech"
