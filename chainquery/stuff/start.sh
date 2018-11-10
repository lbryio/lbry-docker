#!/usr/bin/env bash

# TODO: Remove this notes section.
## Keeping this here as notes for later sed magic.
# #########################
# ## Chainquery Settings ##
# #########################
# RPC_USER=lbryrpc                ## Not super necessery to change this.
# RPC_PASSWORD=changeme           ## Please replace changeme.
# RPC_ALLOW_IP=10.5.1.3           ## You're better off not changing this.
#
# #################
# ## Mysql Creds ##
# #################
# MYSQL_SERVER=10.5.1.10          ## You're better off not changing this.
# MYSQL_USER=changeme             ## This could be changed.
# MYSQL_PASSWORD=changeme         ## This could be set to something random it sets this string for both Mysql's main user and Chainquery's MysqlDSN.
# MYSQL_DATABASE=chainquery       ## This can stay the same.
# MYSQL_ROOT_PASSWORD=changeme    ## Set this to something random and obnoxious we're not using it.

# TODO: Add chainquery startup magic for configuration.
# sed -i ''
#
#
# debugmode=${DEBUGMODE:-false}
# lbrycrdurl="rpc://${RPC_USER:-lbryrpc}:${RPC_PASSWORD:-changeme}@10.5.1.2:9245"
# mysqldsn="${MYSQL_USER:-changeme}:${MYSQL_PASSWORD:-changeme}@tcp(${MYSQL_SERVER:-10.5.1.10}:3306)/${MYSQL_DATABASE:-chainquery}"
# apimysqldsn="${MYSQL_USER:-changeme}:${MYSQL_PASSWORD:-changeme}@tcp(${MYSQL_SERVER:-10.5.1.10}:3306)/${MYSQL_DATABASE:-chainquery}"

## For now keeping this simple. Potentially eventually add all command args as envvars for the Dockerfile or use safe way to add args via docker-compose.yml
chainquery serve -c "/etc/chainquery/"
