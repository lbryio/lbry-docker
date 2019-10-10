#!/usr/bin/env bash

# Override defaults with environment variables
CONFIGFILE="${CONFIGFILE:-/etc/lbry/chainqueryconfig.toml}"
DEBUGMODE="${DEBUGMODE:-false}"
RPC_USER="${RPC_USER:-lbry}"
RPC_PASSWORD="${RPC_PASSWORD:-lbry}"
RPC_HOST="${RPC_HOST:-localhost}"
RPC_PORT="${RPC_PORT:-9245}"
MYSQL_SERVER="${MYSQL_SERVER:-localhost}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-lbry}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-lbry}"
MYSQL_DATABASE="${MYSQL_DATABASE:-chainquery}"

exec_chainquery() {
    CONFIG_DIR=$(dirname "${CONFIGFILE}")
    exec chainquery serve --configpath "$CONFIG_DIR"
}

if [[ -f "$CONFIGFILE" ]]; then
  echo "[INFO]: Found a copy of chainqueryconfig.toml in /etc/lbry"
  exec_chainquery
fi

cat << EOF >> "${CONFIGFILE}"
DEBUGMODE="${DEBUGMODE}"
LBRYCRDURL="rpc://${RPC_USER}:${RPC_PASSWORD}@${RPC_HOST}:${RPC_PORT}"
MYSQLDSN="${MYSQL_USER}:${MYSQL_PASSWORD}@tcp(${MYSQL_SERVER}:${MYSQL_PORT})/$MYSQL_DATABASE"
APIMYSQLDSN="${MYSQL_USER}:${MYSQL_PASSWORD}@tcp(${MYSQL_SERVER}:${MYSQL_PORT})/$MYSQL_DATABASE"
EOF
exec_chainquery
