#!/usr/bin/env bash
sleep 2
while true; do
        lbrycrd-cli -conf=/data/.lbrycrd/lbrycrd.conf generate 1 >> /tmp/output.log
        sleep 10
done