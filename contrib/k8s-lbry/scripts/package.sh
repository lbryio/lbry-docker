#!/bin/bash
## Build Helm package and upload to s3 repository

exe() { echo "\$ $@" ; "$@" ; }

# Work from the parent directory to this script:
cd `dirname "$0"` && cd ..

if s3cmd info s3://k8s-lbry > /dev/null; then
    exe helm dependency update
    exe helm package .
    exe helm repo index .

    exe s3cmd put --acl-public index.yaml k8s-lbry-*.tgz s3://k8s-lbry/
    exe s3cmd put --acl-public charts/*.tgz s3://k8s-lbry/charts/
else
    echo "s3cmd is not setup, run s3cmd --configure"
    exit 1
fi

