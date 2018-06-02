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
  exec "$@"
  exit 1
fi

function configure_speech() {
  # install configuration changes here.
  echof info "At some point there will be code here."
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

# if Spee.ch is not yet installed, copy it into web root.
# This could be updated to be part of an upgrade mechanism.
if [ "$(ls -A /app)" ]; then
  echof warn "/app is not Empty. It contains:" 1>&2
  ls -A 1>&2
  ## If siteConfig.json isn't installed add it and configure or ignore and proceed.
  if [ ! -e '/app/config/siteConfig.json' ]; then
    echof warn "Spee.ch doesn't appear to have a configuration."
    echof blank "Don't worry we can install it for you."
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
  echof info "Speech wasn't installed, installing fresh copy now."
  configure_speech
  echof run "mv /usr/local/src/www.spee.ch/* /app/"
  mv /usr/local/src/www.spee.ch/* /app/
  final_permset
fi

## Superfluous permissions assertion maybe axe this later.
echof run 'test_for_dir /app/config/siteConfig.json 775 "speech:speech"'
test_for_file /app/config/siteConfig.json 775 "speech:speech"
