#!/bin/ash
## This compose file will take a copy of the configuration and install any
## envvars and then copy any required files into the /app/ directory next to any
## custom files added by the user.

# default to run whatever the user wanted like "/bin/ash"
## If user runs no need to run any more of the entrypoint script.
if [[ -z "$@" ]]; then
  echof info "User did not attempt input."
else
  exec "$@"
  exit 1
fi

# if Spee.ch is not yet installed, copy it into web root.
# This could be updated to be part of an upgrade mechanism.
if [ ! -e '/app/config/siteConfig.json' ]; then
	echof warn "Spee.ch doesn't appear to have a configuration."
	echof blank "Don't worry we can install it for you."
	if [ "$(ls -A /app)" ]; then
		echof warn "/app is not Empty. It contains:" 1>&2
		ls -A 1>&2
		echof info "Making an attempt to nicely merge files using."
		echof run "mv -fnu /usr/local/src/www.spee.ch/* /app/"
		mv -fnu /usr/local/src/www.spee.ch/* /app/
	else
		echof run "mv /usr/local/src/www.spee.ch/* /app/"
		mv /usr/local/src/www.spee.ch/* /app/
	fi
	echo "Spee.ch installed into /app"
	# change required permissions incl. for multi-lingual sites
	test_for_dir /app/cli 775 "speech:speech"
	test_for_dir /app/config 775 "speech:speech"
	test_for_dir /app/lib 775 "speech:speech"
	test_for_dir /app/public 775 "speech:speech"
	test_for_dir /app/src 775 "speech:speech"
	test_for_dir /app/utils 775 "speech:speech"
	echof info "Copied Spee.ch and set permissions"
fi

echof run 'test_for_dir /app/config/siteConfig.json 775 "speech:speech"'
test_for_file /app/config/siteConfig.json 775 "speech:speech"
