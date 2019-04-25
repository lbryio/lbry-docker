#!/bin/bash

mountpoint=/home/lbrynet

if ! grep -qs ".* $mountpoint " /proc/mounts; then
    echo "$mountpoint not mounted, refusing to run."
    exit 1
else
    `$@`
fi

