# lbrycrd cloud-init with systemd

Contributing Author: [EnigmaCurry](https://www.enigmacurry.com)

Last Update: April 17 2019

This is meant to be the easiest instructions possible for running a full lbrycrd
node on DigitalOcean. It's pretty much just cut-and-paste.

This should also work on any host that supports
[cloud-init](https://cloud-init.io/), but I've not tested it anywhere except for
DigitalOcean.

If you wish to use docker-compose, there is an [alternative
configuration](https://github.com/lbryio/lbry-docker/tree/master/lbrycrd)
for that. This tutorial will use cloud-init and systemd to control docker.

## It's easy to run your own full lbrycrd node

[![Video of creating lbrycrd droplet on DigitalOcean](https://spee.ch/@EnigmaCurry:d/lbrycrd-video-thumb.jpg)](https://spee.ch/@EnigmaCurry:d/lbrycrd-docker-cloud-init.mp4)

## Installation

 * Login to your DigitalOcean account and create a new droplet.
 * Choose Ubuntu 18.04. (This will likely NOT work on other versions without tweaks.)
 * Select a Standard droplet with 8GB of memory ($40 per month in 2019.)
   * You may be able to get away with only 4GB.
 * Select whatever datacenter you want.
 * Mark the checkbox called `User data`, and paste the following into the box:
 
```
#cloud-config

## DigitalOcean user-data for Ubuntu 18.04 droplet
## Installs docker
## Setup systemd service for lbrycrd
## (This config just runs docker on vanilla Ubuntu,
##  it uses systemd inplace of docker-compose or kubernetes.)

write_files:
  - path: "/etc/lbry/lbrycrd.conf"
    content: |
      datadir=/data
      port=9246
      rpcuser=test
      rpcpassword=test
      rpcport=9245
      regtest=0
      server=1
      txindex=1
      daemon=0
      listen=1

  - path: "/etc/systemd/system/lbrycrd.service"
    content: |
      [Unit]
      Description=lbrycrd docker container
      After=snap.docker.dockerd.service
      Requires=snap.docker.dockerd.service

      [Service]
      TimeoutStartSec=0
      ExecStartPre=-/snap/bin/docker stop lbrycrd
      ExecStart=/snap/bin/docker run \
        --rm \
        --name lbrycrd \
        -p 9246:9246 \
        -p 127.0.0.1:9245:9245 \
        --mount type=volume,source=lbrycrd-data,target=/data \
        --mount type=bind,source=/etc/lbry/lbrycrd.conf,target=/etc/lbry/lbrycrd.conf \
        --hostname lbrycrd \
        -e RUN_MODE=default \
        lbry/lbry-docker:lbrycrd-production
      ExecStop=/snap/bin/docker stop lbrycrd
      Restart=always
      RestartSec=120

      [Install]
      WantedBy=multi-user.target

  - path: "/root/.bash_aliases"
    content: |
      alias lbrycrd-cli="docker exec lbrycrd lbrycrd-cli -conf=/etc/lbry/lbrycrd.conf"

runcmd:
  - apt-get update
  - DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
  - snap install docker
  - until /snap/bin/docker ps; do echo "Waiting for docker startup..."; sleep 1; done; echo "Docker is up."
  - /snap/bin/docker volume create lbrycrd-data
  - systemctl enable --now lbrycrd
  - echo "Good to go."
``` 
 * Select your SSH key so you can login.
 * Give it a good hostname.
 * Click Create.

## Usage

### How to administer the system

Copy the IP address from the droplet status page, SSH into the droplet as root
using the same SSH key you configured for the droplet.

The config file is in `/etc/lbry/lbrycrd.conf` on the host.

The systemd service is called `lbrycrd`, in
`/etc/systemd/system/lbrycrd.service`. It is preconfigured to start on system
startup.

#### Monitor the installer log

You can tail the log to monitor the install progress:

```
tail -f /var/log/cloud-init-output.log 
```

Wait for the final `Good to go` message to know that the installer has finished.

#### Check the status of the systemd service

You can interact with systemd using `systemctl` (status, start, stop, restart,
etc.) and `journalctl` (logging) tools.

```
systemctl status lbrycrd
```

```
journalctl --unit lbrycrd
```

[Here is a tutorial to get you familiarized with
systemd](https://www.digitalocean.com/community/tutorials/systemd-essentials-working-with-services-units-and-the-journal)

#### Check the container

You can get the same information directly from docker:

```
docker ps
```

```
docker logs lbrycrd
```

### Utilize lbrycrd-cli

You can use lbrycrd-cli from the host console. A bash alias has been added to
/root/.bash_aliases that invokes the lbrycrd-cli inside the running container.

```
$ lbrycrd-cli getinfo
{
  "version": 120400,
  "protocolversion": 70013,
  "walletversion": 60000,
  "balance": 0.00000000,
  "blocks": 551965,
  "timeoffset": 0,
  "connections": 12,
  "proxy": "",
  "difficulty": 739465688254.7942,
  "testnet": false,
  "keypoololdest": 1555360604,
  "keypoolsize": 101,
  "paytxfee": 0.00000000,
  "relayfee": 0.00001000,
  "errors": ""
}
```
