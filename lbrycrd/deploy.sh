#!/bin/bash

set -euo pipefail

hash docker 2>/dev/null || { echo >&2 'Make sure Docker is installed'; exit 1;  }

set +eo pipefail
docker version | grep -q Server
ret=$?
set -eo pipefail

if [ $ret -ne 0 ]; then
  echo "Cannot connect to Docker server. Is it running? Do you have the right user permissions?"
  exit 1
fi

echo "This will build the docker image using the latest lbrycrd release and push that image to Docker Hub"
echo ""

echo "What Docker tag should I use? It's the part that goes here: lbry/lbrycrd:TAG"

read -p "Docker tag: " docker_tag
if [ -z "$docker_tag" ]; then
  echo "Docker tag cannot be empty"
  exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

docker build -t "lbry/lbrycrd:${docker_tag}" -f Dockerfile-linux-x86_64-production "$DIR"
docker push "lbry/lbrycrd:${docker_tag}"
