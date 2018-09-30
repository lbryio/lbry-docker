## lbrynet-As-A-Container

I'll document a bit of this later but for now you may look over ```docker-compose.yml``` and then modify any environment variables you feel the need to.

#### Invocation
This will get you a running copy of the lbrynet-daemon running inside of a docker container with default settings.
```
git clone https://github.com/chamunks/lbry-docker.git
cd ./lbry-docker/lbrynet-daemon/
docker-compose up -d
```

#### Executing commands

To list containers on the host execute `docker ps -a` then run `docker exec CONTAINERNAME lbrynet-cli commands`

#### Docker Directory

This directory is in case we need to expand the functionality of this container at some point in the future.

#### Configuration
There's really no configuration required to launch this just launch it.  However your blockchain data and other things are currently located in the applications home Directory here's a link to the [Documentation](https://lbry.io/faq/lbry-directories) for useful directories with lbrynet-daemon
