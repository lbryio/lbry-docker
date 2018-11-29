#!/usr/bin/env bash
docker network create -d bridge --subnet=10.6.1.0/16 lbry-network
