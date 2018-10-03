#!/bin/bash

## Ensure perms are correct prior to running main binary
chown -R 1000:1000 /data
chmod -R 755 /data

## For now keeping this simple. Potentially eventually add all command args as envvars for the Dockerfile or use safe way to add args via docker-compose.yml
chainquery
