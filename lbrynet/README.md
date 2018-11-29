## lbrynet-As-A-Container

More documentation to come however the Invocation section should include enough to get you going.  You're going to need at least docker docker-compose and git installed on whatever host OS you wish to use.

#### Invocation
This will get you a running copy of the lbrynet-daemon running inside of a docker container with default settings.
```
git clone https://github.com/chamunks/lbry-docker.git
cd ./lbry-docker/lbrynet/
docker-compose up -d
```

#### Executing commands

To list containers on the host execute `docker ps -a` then run `docker exec CONTAINERNAME lbrynet-cli commands`

#### Docker Directory

This directory is in case we need to expand the functionality of this container at some point in the future.

#### Configuration
There's really no configuration required to launch this just launch it.  However your blockchain data and other things are currently located in the applications home Directory here's a link to the [Documentation](https://lbry.io/faq/lbry-directories) for useful directories with lbrynet-daemon

*daemon_settings.yml* is on its way and it will be configurable soon via env-vars with *docker-compose.yml*
