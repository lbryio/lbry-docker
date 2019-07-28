#!/bin/bash
CONFIG_PATH=/etc/lbry/daemon_settings.yml

echo "Config: "
cat $CONFIG_PATH

lbrynet start --config $CONFIG_PATH

