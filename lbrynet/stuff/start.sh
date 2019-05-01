#!/bin/bash
CONFIG_PATH=/etc/lbry/daemon_settings.yml

echo "Config: "
cat $CONFIG_PATH

lbrynet start --api 0.0.0.0:5279 --config $CONFIG_PATH

