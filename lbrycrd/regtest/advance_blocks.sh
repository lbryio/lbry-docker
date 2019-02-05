#!/usr/bin/env bash
while true; do
        lbrycrd-cli -conf=/data/.lbrycrd/lbrycrd.conf generate 50 >> /tmp/output.log
        sleep 1
done