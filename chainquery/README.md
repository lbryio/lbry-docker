## Get the lbry-docker repository

`git clone https://github.com/lbryio/lbry-docker.git`

## Setup networking

You only need external networking if you plan on keeping your docker-compose files separate.
For the sake of modularity in the design of this git repository the plan is to give you examples to try and then you're supposed to move towards your own custom docker-compose configuration.  We're going to create
a docker bridge network that is going to be managed externally to your usual docker-compose networks which are compose internal.

`docker network create -d bridge --subnet=10.5.1.0/16 lbrynet`

## Make directories and set permissions

This is only required on host mounted volumes. (the default settings)

`mkdir -p ./lbry-docker/lbrycrd/data`

`chmod -R 755 ./lbry-docker/lbrycrd/data`

## Setup lbrycrd

`cd lbry-docker/lbrycrd`

`docker-compose up -d && docker-compose logs -f`

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

Add a PORTS directive for binding chainquery to the host and then run.

`./quick-bootstrap.sh start`

*OR*

`docker-compose up -d mysql && sleep 30 && docker-compose up -d chainquery`
