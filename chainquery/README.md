# Installation instructions for Chainquery and dependencies
## Preface
I have set up this tutorial so that you should be able to copy and paste the commands into your Linux console.  However, if you run into issues, please be sure to read the detailed expansions on the current and prior steps to ensure you didn't miss a detail.

## Caveats to installing Chainquery
Chainquery is an interface to an extensive index of data which has to parse an entire blockchain's history into a SQL database in a way that is easily query-able.  The process of syncing your lbrycrd level.db files can take a long time depending on your deployment and then once your instance is synced you need to index the blockchain with Chainquery.  All of this takes a fair bit of time or resources at first it is possible to deploy this stack without the shell scripts, and I will eventually include a docker-compose.yml file which gives you a baseline for deploying this to k8's and other platforms but for now single host deployment via shell script will be what's supported.

## Goals of this README.md
This readme is targeted towards people who need a copy paste recipe to get Chainquery online and running asap and with some degree of repeatability.  Once this is up and running on your machine, you should be able to see what a running instance of Chainquery looks like and start writing apps against its API.

## Dependencies
My goal is to avoid as many dependencies as possible so for now the only pre-requisites you are required to have are `git`, `docker`, and `docker-compose` for the most part your understanding of the technologies can be superficial so long as you can follow commands and are open to reading a bit you should be fine.

### Docker

Docker is effectively the cross-platform software package repository it allows you to ship an entire environment in what's referred to as a container. Containers are intended to hold everything that is needed to ship what's required to run an application from one place to another with a degree of a standard that makes it easy for everyone along the way to reproduce the environment for their step in the chain.

The other side of docker is it brings everything that we would typically have to teach you about the individual components of your soon to be installed Chainquery, Lbrycrd, and MySQL stack and wraps it up nicely in a handful of easy to follow steps that should result in the same environment on everyone's host.

The installation method we recommend is via the `docker.com` website however if your specific operating system's repository versions are at the latest along with docker you should be good to launch with you using whatever instructions you wish.  The version of Docker we used in our deployment for testing this process was `Docker version 17.05.0-ce, build 89658be` however any versions later than this is sufficient.  At the writing of this tutorial, this was not the latest version of Docker.

#### Just the link to installation instructions, please
Instructions for installing on Ubuntu are at the link that follows:
https://docs.docker.com/install/linux/docker-ce/ubuntu/

If you plan on using other versions of OS you should at least aim to be a Linux base with an x86_64 CPU and the appropriate minimum version of the dependencies.

### Docker-compose
Docker Compose's role in this deployment is to get you a fully working cluster of microservices in containers that will deploy Chainquery, MySQL, and LBRYCrd exactly as you would need it to have a reasonable instance for testing / developing on.  You are encouraged to learn how to use the Docker-Compose format, but it's not a required prerequisite for getting this running you need to have it installed successfully.

Install Docker Compose via this guide below, and it is essential if you're using an older version of Linux to use the official documentation from Docker.com because you require the more recent version of docker-compose at least version 3.4 aka 1.22.0 or newer.

#### Just the link to installation instructions, please
https://docs.docker.com/compose/install/

### Git
For now, the recommended install includes grabbing the latest git repository from https://github.com/lbryio/lbry-docker for this you're going to need to install git with the following command.  The amount of git knowledge required for this is ideally reasonably minimal.

#### Just the instructions, please
`apt-get install git -y`

## Get the lbry-docker repository

`sudo git clone https://github.com/lbryio/lbry-docker.git`

## Setup networking

You only need external networking if you plan on keeping your docker-compose files separate.
For the sake of modularity in the design of this git repository, the plan is to give you examples to try and then you're supposed to move towards your custom docker-compose configuration.  We're going to create
a docker bridge network that is going to be managed externally to your usual docker-compose networks which are docker-compose internal.

`docker network create -d bridge --subnet=10.6.1.0/16 lbry-network`

## Make directories and set permissions

Setting permissions is only typically required on host mounted volumes. (the default settings)

`sudo mkdir -p ./lbry-docker/lbrycrd/data`

`sudo chmod -R 755 ./lbry-docker/lbrycrd/data`

`sudo chown -R 1000:1000 ./lbry-docker/lbrycrd/data`

## Setup lbrycrd

`cd lbry-docker/lbrycrd`

`sudo docker-compose up -d && docker-compose logs -f`

Wait for lbrycrd to reach the top of the blockchain (console output should noticeably slow down)

Once you've reached the top of the blockchain, you can press `CTRL+C` to exit back to the Linux shell.

## Setup chainquery

Now you're finished syncing your copy of the lbry blockchain into the `lbrycrd` instance you can start spinning up Chainquery, and it's dependencies since Chainquery is parsing copious amounts of unstructured data stored in the `lbry` blockchain you have two routes to go.

1. Route number one [Recommended]: You use some variant of this README.md's instructions to start your chainquery instance using an LBRY.io provided database checkpoint snapshot.  The checkpoint should be copy-paste-able series of commands to get your staging instance up asap if you want Route number one, follow along with the rest of this README.md
2. Route number two: You can your fresh copy of the chainquery database indexing times may vary from hours to days depending on your hardware.

`cd ../chainquery/`

`cat ./compose/docker-compose.yml-prod-example > docker-compose.yml`

`./quick-bootstrap.sh getdata`

`./quick-bootstrap.sh extract`

## docker-compose.override.yml

`./quick-bootstrap.sh start`

*OR*

`docker-compose up -d mysql && sleep 30 && docker-compose up -d chainquery`
