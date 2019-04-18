# LBRY cloud-init with systemd

Contributing Author: [EnigmaCurry](https://www.enigmacurry.com)

Last Update: April 18 2019

This is meant to be easy instructions for running a lbrycrd and chainquery
service on DigitalOcean. It's pretty much just copy-and-paste.

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
      rpcuser=lbry
      rpcpassword=lbry
      rpcport=9245
      rpcallowip=172.17.0.0/16
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
      Environment=SERVICE=lbrycrd
      Environment=IMAGE=lbry/lbry-docker:lbrycrd-production
      TimeoutStartSec=0
      ExecStartPre=-/snap/bin/docker stop $SERVICE
      ExecStartPre=-/snap/bin/docker rm -f $SERVICE
      ExecStartPre=-/snap/bin/docker pull $IMAGE
      ExecStart=/snap/bin/docker run \
        --rm \
        --name lbrycrd \
        -p 9246:9246 \
        -p 127.0.0.1:9245:9245 \
        --mount type=volume,source=lbrycrd-data,target=/data \
        --mount type=bind,source=/etc/lbry/lbrycrd.conf,target=/etc/lbry/lbrycrd.conf \
        -e RUN_MODE=default \
        $IMAGE
      ExecStop=/snap/bin/docker stop $SERVICE
      Restart=always
      RestartSec=60
      
      [Install]
      WantedBy=multi-user.target

  - path: "/etc/mysql/conf.d/chainquery.cnf"
    content: |
      # Put mysql optimizations specific to chainquery here
      
  - path: "/etc/systemd/system/mysql.service"
    content: |
      [Unit]
      Description=mysql docker container
      After=snap.docker.dockerd.service
      Requires=snap.docker.dockerd.service

      [Service]
      Environment=SERVICE=mysql
      Environment=IMAGE=mysql:5
      TimeoutStartSec=0
      ExecStartPre=-/snap/bin/docker stop $SERVICE
      ExecStartPre=-/snap/bin/docker rm -f $SERVICE
      ExecStartPre=-/snap/bin/docker pull $IMAGE
      ExecStart=/snap/bin/docker run \
        --rm \
        --name mysql \
        --mount type=volume,source=mysql-data,target=/var/lib/mysql \
        --mount type=bind,source=/etc/mysql/conf.d/chainquery.cnf,target=/etc/mysql/conf.d/chainquery.cnf \
        -e MYSQL_USER=chainquery \
        -e MYSQL_PASSWORD=chainquery \
        -e MYSQL_DATABASE=chainquery \
        -e MYSQL_ROOT_PASSWORD=chainquery \
        $IMAGE
      ExecStop=/snap/bin/docker stop $SERVICE
      Restart=always
      RestartSec=60
      
      [Install]
      WantedBy=multi-user.target

  - path: "/etc/lbry/chainqueryconfig.toml"
    content: |
      ### Reference config: https://raw.githubusercontent.com/lbryio/chainquery/master/config/default/chainqueryconfig.toml
      lbrycrdurl="rpc://lbry:lbry@lbrycrd:9245"
      mysqldsn="chainquery:chainquery@tcp(mysql:3306)/chainquery"
      apimysqldsn="chainquery:chainquery@tcp(mysql:3306)/chainquery"
      
  - path: "/etc/systemd/system/chainquery.service"
    content: |
      [Unit]
      Description=chainquery docker container
      After=mysql.service
      Requires=mysql.service
      Requires=snap.docker.dockerd.service

      [Service]
      Environment=SERVICE=chainquery
      Environment=IMAGE=lbry/lbry-docker:chainquery-production
      TimeoutStartSec=0
      ExecStartPre=-/snap/bin/docker stop $SERVICE
      ExecStartPre=-/snap/bin/docker rm -f $SERVICE
      ExecStartPre=-/snap/bin/docker pull $IMAGE
      ExecStart=/snap/bin/docker run \
        --rm \
        --name chainquery \
        -p 127.0.0.1:6300:6300 \
        --mount type=bind,source=/etc/lbry/chainqueryconfig.toml,target=/etc/lbry/chainqueryconfig.toml \
        --link mysql:mysql \
        --link lbrycrd:lbrycrd \
        $IMAGE
      ExecStop=/snap/bin/docker stop $SERVICE
      Restart=always
      RestartSec=60
        
      [Install]
      WantedBy=multi-user.target


  - path: "/root/.bash_aliases"
    content: |
      alias lbrycrd-cli="docker run --rm -it --link lbrycrd:lbrycrd --mount type=bind,source=/etc/lbry/lbrycrd.conf,target=/etc/lbry/lbrycrd.conf \
          lbry/lbry-docker:lbrycrd-production lbrycrd-cli -conf=/etc/lbry/lbrycrd.conf -rpcconnect=lbrycrd"
      alias mysql="docker run --rm -it --link mysql:mysql mysql:5 mysql -hmysql -u chainquery --password=chainquery"

runcmd:
  - apt-get update
  - DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
  - snap install docker
  - until /snap/bin/docker ps; do echo "Waiting for docker startup..."; sleep 1; done; echo "Docker is up."
  - /snap/bin/docker volume create lbrycrd-data
  - /snap/bin/docker volume create mysql-data
  - systemctl enable --now lbrycrd
  - echo "Good to go."
``` 
 * You can leave everything above as it is, to use the default configuration, OR
   you may edit the config in the box to your own liking.
     * For instance, if you wanted to run in [regtest
       mode](https://lbry.tech/resources/regtest-setup), you would set
       `regtest=1` in the first section under `write_files`.
     * You can also edit the config files at any later point in `/etc/lbry`,
       after you create the droplet.
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
(Press Ctrl-C to exit from tail.)

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
`/root/.bash_aliases` that invokes lbrycrd-cli in its own container.

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

### Chainquery (optional)

The chainquery service is pre-installed, but it is not enabled by default.

#### Enable and start the mysql service

```
systemctl enable --now mysql
```

In case you need it, there is a bash alias called `mysql`
(`/root/.bash_aliases`) for the mysql client that allows you to login to the
chainquery database.

#### Enable and start the chainquery service

The chainquery config file is located on the host: `/etc/lbry/chainqueryconfig.toml`

```
systemctl enable --now chainquery
```

In systemd, when you enable a service, it means to always start the service at
system boot. (`--now` just means you also want to start the service right away.)

As with any service, you can control chainquery with `systemctl` and get logs
with `journalctl`:

##### Starting and stopping chainquery service
```
systemctl start chainquery
```

```
systemctl stop chainquery
```

##### Getting the chainquery service logs

```
journalctl --unit chainquery
```

(optionally use `-f` if you want to tail/follow the logs)

##### Disabling chainquery service 

```
systemctl disable --now chainquery
```

### Known issues

Ubuntu's snap update mechanism will apparently [restart docker even if there are
no updates
available](https://github.com/lbryio/lbry-docker/pull/50#issuecomment-485435736).
In the future, this tutorial may replace the snap version of docker with the
regular PPA version of docker-ce, which has a more predictable update strategy
(apt-get) rather than auto-updates. More long term testing is needed to know
which way is better.

