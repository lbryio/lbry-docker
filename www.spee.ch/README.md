<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Container Base](#container-base)
	- [Goals](#goals)
			- [Fresh install on creation](#fresh-install-on-creation)
			- [Your changes take priority](#your-changes-take-priority)
			- [Configuration](#configuration)
- [Try it out immediately](#try-it-out-immediately)
	- [Docker & Docker-compose](#docker-docker-compose)

<!-- /TOC -->

# Container Base
[Based on this documentation](https://docs.google.com/document/d/1eeEx1wNVxfFEzxC4P_tL4-peZiUjD0KL_ODkKvEucrk/edit) I will be creating a container which should aim to work on top of any customizations you add yourself.  

## Goals
#### Fresh install on creation
The end goal will be to iterate through all of the directories you have in any volumes you include and then copy anything else into the service directory omitting any files which you've changed.

Configuration should be absolutely bare minimal and doable via the docker environment variables.  This makes it so that you can launch this project in any environment you like Kubernetes, Amazon Elastic Container Service, RancherOS, Docker Swarm, Docker-Compose.

An advanced container example using docker-compose which contains the full stack including https handling via a reverse proxy.  This should automagically by default include automagic LetsEncrypt provisioning and renewal so long as you've set your own DNS records correctly to point where this container will be hosted.

#### Your changes take priority
This means any content that you've included in the /app/ path should be ignored when the container is instantiated.  So generally only include files that you plan to have changed.  Eventually I may add something a bit smarter and do a hash check & compare to be a bit smarter but for now simpler is better.

#### Configuration
The configuration will take place on container instantiation based on any environment variables which you include in your docker invocation be it a `docker-compose.yml` or a simple `docker run`.  

You should prefer to include your configuration variables through means of the environment variables. However, if you find something in the configuration which you feel needs changed which we haven't included an environment variable for you should be free to include your own custom configuration file you're welcomed to.

# Try it out immediately
What's better than something that works right out of the box?  I really have no idea because if you have a goal that is small and iterative why would you want to do things the hard way unless you know for a fact that you're really into this.

## Docker & Docker-compose
Docker compose is the most recommended way to get started and even run in deployment as it saves you a lot of pain of sifting through old commands to re-execute your docker container.  So pre-requisites will be to have the following installed and most of these support packages are as easy as copy paste commands.
```
git
docker
docker-compose
```
