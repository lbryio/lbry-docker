#!/bin/ash
set -euxo pipefail
## This docker-entrypoint will take a copy of the configuration and install any
## envvars and then copy any required files into the /app/ directory next to any
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

envvars=("$MYSQL_ENV_MYSQL_USER" "$MYSQL_ENV_MYSQL_PASSWORD" "$MYSQL_ENV_MYSQL_DATABASE" "$MYSQL_ENV_MYSQL_ADDRESS" "$GOOGLE_ANALYTICS_UID" "$SITE_TITLE" "$SITE_ADDRESS" "$SITE_DESCRIPTION")

function set_conf() {
  case $1 in
    $MYSQL_ENV_MYSQL_USER )
      /bin/ash echof info "Setting '$MYSQL_ENV_MYSQL_USER' $1 in /app/config/mysqlConfig.json"
      sed -i 's/"username": "root"/"username": "'$MYSQL_ENV_MYSQL_USER'"/' /app/config/mysqlConfig.json
    ;;
    $MYSQL_ENV_MYSQL_PASSWORD )
      ## This echo should be sanitized of any secrets before this is finished.
      /bin/ash echof info "Setting '$MYSQL_ENV_MYSQL_PASSWORD' $1 in /app/config/mysqlConfig.json"
      sed -i 's/"password": ""/"password": "'$MYSQL_ENV_MYSQL_PASSWORD'"/' /app/config/mysqlConfig.json
      ;;
    $MYSQL_ENV_MYSQL_DATABASE )
      /bin/ash echof info "Setting '$MYSQL_ENV_MYSQL_DATABASE' $1 in /app/config/mysqlConfig.json"
      sed -i 's/"database": "lbry"/"database": "'$MYSQL_ENV_MYSQL_DATABASE'"/' /app/config/mysqlConfig.json
    ;;
    $MYSQL_SERVER_ADDRESS )
      /bin/ash echof warn "This variable is not currently available."
    ;;
    $SITE_ADDRESS )
      /bin/ash echof info "Setting '$SITE_ADDRESS' $1 in /app/config/siteConfig.json"
      sed -i 's/"host": "https://www.example.com"/"host": "https://'$SITE_ADDRESS'"/' /app/config/siteConfig.json
    ;;
    $GOOGLE_ANALYTICS_UID )
      /bin/ash echof info "Setting '$GOOGLE_ANALYTICS_UID' $1 in /app/config/siteConfig.json"
      sed -i 's/"googleId": null/"googleId": '$GOOGLE_ANALYTICS_UID'/' /app/config/siteConfig.json
    ;;
    $SITE_TITLE )
      /bin/ash echof info "Setting '$SITE_TITLE' $1 in /app/config/siteConfig.json"
      sed -i 's/"title": "My Site"/"title": "'$SITE_TITLE'"/' /app/config/siteConfig.json
    ;;
    $SITE_DESCRIPTION )
      /bin/ash echof info "Setting '$SITE_DESCRIPTION' $1 in /app/config/siteConfig.json"
      sed -i 's/"description": "A decentralized hosting platform built on LBRY"/"Description": "'$SITE_DESCRIPTION'"/' /app/config/siteConfig.json
    ;;
  esac
}

function configure_speech() {
  # install configuration changes here.
  /bin/ash echof info "Installing configuration files into /app/config/."
  mkdir -p /app/config/
  cp /usr/local/src/www.spee.ch/cli/defaults/mysqlConfig.json > /app/config/mysqlConfig.json
  cp /usr/local/src/www.spee.ch/cli/defaults/siteConfig.json > /app/config/siteConfig.json
  /bin/ash echof info "Installing any environment variables that have been set."
  for i in "${envvars[@]}"; do
    if [[ -z "$i" ]]; then
      /bin/ash echof info "$i was not set, moving on."
    else
      set_conf $i
    fi
  done
}

function final_permset() {
  ## Finally reassert permissions in case there is user added drift.
  rddo /app "/bin/ash test_for_dir" '775 "speech:speech"'
  rfdo /app "/bin/ash test_for_file" '665 "speech:speech"'
  ## Define any permission exceptions here.
  # /bin/ash test_for_dir /app/config 775 "speech:speech"
  # /bin/ash test_for_file /app/config/siteConfig.json 665 "speech:speech"
  /bin/ash echof info "Copied Spee.ch and set permissions"
}

###################################
## Actual installation function. ##
###################################
# if Spee.ch is not yet installed, copy it into web root.
# This could be updated to be part of an upgrade mechanism.
if [ "$(ls -A /app)" ]; then
  /bin/ash echof warn "/app is not Empty. It contains:" 1>&2
  ls -A 1>&2
  ## If siteConfig.json isn't installed add it and configure or ignore and proceed.
  if [ ! -e '/app/config/siteConfig.json' ]; then
    /bin/ash echof warn "Spee.ch doesn't appear to have a configuration."
    /bin/ash echof blank "Don't worry we can install it for you."
    configure_speech
  else
    ## If the file exists skip configuration and proceed.
    /bin/ash echof info "Spee.ch config already installed skipping configuration step."
    final_permset
  fi
  ## Install all other files after installing siteConfig.json
  /bin/ash echof info "Making an attempt to nicely merge files using:"
  /bin/ash echof run "mv -fnu /usr/local/src/www.spee.ch/* /app/"
  mv -fnu /usr/local/src/www.spee.ch/* /app/
  final_permset
else
  /bin/ash echof info "Speech wasn't installed, installing fresh copy now."
  configure_speech
  /bin/ash echof run "mv /usr/local/src/www.spee.ch/* /app/"
  mv /usr/local/src/www.spee.ch/* /app/
  final_permset
fi

## Superfluous permissions assertion maybe axe this later.
/bin/ash echof run '/bin/ash test_for_dir /app/config/siteConfig.json 775 "speech:speech"'
/bin/ash test_for_file /app/config/siteConfig.json 775 "speech:speech"
