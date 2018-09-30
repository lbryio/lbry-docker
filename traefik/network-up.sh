#!/bin/bash
docker network create -d bridge --subnet=10.5.0.10/16 traefik
