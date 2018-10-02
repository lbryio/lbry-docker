#!/bin/bash

# default to run whatever the user wanted like "/bin/bash"
## If user runs no need to run any more of the entrypoint script.
if [[ -z "$@" ]]; then
  echo "User did not attempt input. Now executing docker-entrypoint."
else
  echo "Running $@."
  exec "$@"
  exit 1
fi

/bin/bash
