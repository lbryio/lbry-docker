# Installation instructions for Chainquery and dependencies
## Preface
I have set up this tutorial so that you should be able to simply copy and paste the commands into your linux console.  However if you run into issues please be sure to read the detailed expansions on the current and prior steps to ensure you didn't miss a detail.

## Goals of this README.md
This readme is targeted towards people who need a copy pasta recipe to get Chainquery online and running asap and with some degree of repeatability.  Once this is up and running on your machine you should be able to see what a running instance of Chainquery looks like and start writing apps against it's API calls etc.

## Dependencies
My goal is to avoid as many dependencies as possible so for now the only pre-requisites you are required to have will be `git`, `docker`, and `docker-compose` for the most part your understanding of the technologies can be superficial so long as you can follow commands and are open to reading a bit you should be fine.

### Docker
Docker
Docker is effectively the cross platform software package repository it allows you to ship an entire environment in what's referred to as a container.  Implying that containers hold everything that is needed to ship what's inside effectively from one place to another with a degree of standard that makes it easy for everyone along the way to replicate what is needed for their step in the chain.  

The other side of docker is it brings everything that we would normally have to teach you about the individual components of your soon to be installed Chainquery, Lbrycrd, and MySQL stack and wraps it up nicely in a handfull of easy to follow steps that should result in the same environment on everyones host.

The installation method we recommend is via the `docker.com` website however if your specific operating system's repository versions are at the latest along with docker you should be good to launch with you using whatever instructions you wish.  The version of Docker we used in our deployment for testing this process was `Docker version 17.05.0-ce, build 89658be` however any versions later than this will suffice.  At the writing of this tutorial this was not the latest version of Docker.

#### Just the link to installation instructions please
Instructions for installing on Ubuntu are at the link that follows:
https://docs.docker.com/install/linux/docker-ce/ubuntu/

If you plan on using other versions of OS you should at least aim to be a linux base with a x64 CPU and the appropriate minimum version of the dependencies.

### Docker-compose
Docker Compose's role in this deployment is to get you a fully working cluster of microservices in containers that will deploy Chainquery, MySQL, and LBRYCrd exactly as you would need it to have a reasonable instance for testing / developing on.  You are encouraged to learn how to use the Docker-Compose format but it's not a required prerequisite for getting this running you just need to have it installed successfully.

Install Docker Compose via this guide below, its important if you're using an older version of linux to use the official documentation from Docker.com because you will need the more recent version of docker-compose at least version 3.4 aka 1.22.0 or newer.

#### Just the link to installation instructions please
https://docs.docker.com/compose/install/

### Git
For now the recommended install includes grabbing the latest git repository from https://github.com/lbryio/lbry-docker for this you're going to need to install git with the following command.  The amount of git knowledge required for this is ideally fairly minimal.

#### Just the instructions please
`apt-get install git -y`

## Get the lbry-docker repository

`sudo git clone https://github.com/lbryio/lbry-docker.git`

## Setup networking

You only need external networking if you plan on keeping your docker-compose files separate.
For the sake of modularity in the design of this git repository the plan is to give you examples to try and then you're supposed to move towards your own custom docker-compose configuration.  We're going to create
a docker bridge network that is going to be managed externally to your usual docker-compose networks which are compose internal.

`docker network create -d bridge --subnet=10.6.1.0/16 lbrynet`

## Make directories and set permissions

This is only required on host mounted volumes. (the default settings)

`sudo mkdir -p ./lbry-docker/lbrycrd/data`

`sudo chmod -R 755 ./lbry-docker/lbrycrd/data`

`sudo chown -R 1000:1000 ./lbry-docker/lbrycrd/data`

## Setup lbrycrd

`cd lbry-docker/lbrycrd`

`sudo docker-compose up -d && docker-compose logs -f`

Wait for lbrycrd to reach the top of the blockchain (console output should noticeably slow down)

Once you've reached the top of the blockchain you can press `CTRL+C` to exit back to the linux shell.

## Setup chainquery

Now that you're done syncing your own copy of the lbry blockchain into the `lbrycrd` instance you can start spinning up Chainquery and it's dependencies.  Since Chainquery is parsing copious amounts of unstructured data stored in the `lbry` blockchain you have two routes to go.

1. Route number one [Recommended]: You use some variant of this README.md's instructions to start your chainquery instance using a LBRY.io provided database checkpoint snapshot.  This should be basically copy paste-able series of commands to get your own staging instance up asap if you want Route number one, follow along with the rest of this README.md
2. Route number two: You can your own fresh copy of the chainquery database indexing times may vary from hours to days depending on your hardware.

`cd ../chainquery/`

`./quick-bootstrap.sh getdata`

`./quick-bootstrap.sh extract`

## docker-compose.override.yml

`./quick-bootstrap.sh start`

*OR*

`docker-compose up -d mysql && sleep 30 && docker-compose up -d chainquery`
