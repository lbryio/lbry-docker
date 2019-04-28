# lbry-Docker

## Tags
<!-- Document tags and link to their Dockerfiles here. -->

## Scope
This repository aims to track and maintain most of the Dockerfiles within the LBRY Inc ecosystem.  

Currently it supports the following in various form factors:
* Lbrycrd
* Lbrynet
* Chainquery

If you see an architecture that you have a use case for that you don't see in this list and it's stopping you from innovating on the LBRY blockchain search and bump an existing request or create a feature request ASAP on the issue tracker and we will do our best to support your architecture or build requirements.

The goals here will be to create containers that can deploy across a number of technologies namely `docker-compose`, `docker` itself, and Kubernetes k8's.

There will be a few edge cases where this repository will support installing these containers as a service on a machine using `cloud-init` however those come as a YMMV(your mileage may vary) warranty void if used.

We may suggest the use of well commented **`Shell scripts`**, Dockerfiles, and Docker-Compose which is a template that is a baseline for many other container management services such as [RancherOS](https://rancher.com/rancher-os/) and [Kubernetes](https://kubernetes.io/).

#### Goals
We have a number of priorities within this docker container repository.
Loosely defined our priorities are in the order as follows ordered highest priority to lowest.

1. Congruency - Containers should all behave similarly.
2. Safety - Cautioning the user when they're in a danger zone when possible.
3. Reliability - Only pushing functional tested containers to production allowing users to impose an update schema.
4. Ephemerality/Statelessness - You should be able to define the entire state in a cross cloud platform way such that the container itself should contain no state and thus have no reason to rely on it's specific contents as best as possible.
5. Works by default - As best as possible we will aim for these containers to work by default out of the box then if you wish you can find ways to improve upon what we've set out for the user on your own.
6. Flexibility - Despite all of the above we want people to be able to utilize all of the functionalities of the appliances contained within these containers.  This means if you find that our system/implementation gets in your way this is one of our priorities to fix this.

In summary, this repository aims for [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) minimalism, ephemerality, and statelessness.



#### Beautiful Screenshot/Gif
Here's an example tutorial we have for how to get some of our appliances up and running in minutes on DigitalOcean all hosted on our very own platform https://spee.ch a link to the guide is [here](https://github.com/lbryio/lbry-docker/blob/master/contrib/systemd-cloud-init.md) it contains a few lines of information and some copy paste-able code!

[![Video of creating lbrycrd droplet on DigitalOcean](https://spee.ch/@EnigmaCurry:d/lbrycrd-video-thumb.jpg)](https://spee.ch/@EnigmaCurry:d/lbrycrd-docker-cloud-init.mp4)


## Installation

There are a few methods we're planning on releasing over time however two notable options are our [cloud-init](https://github.com/lbryio/lbry-docker/blob/master/contrib/systemd-cloud-init.md) install of lbrycrd and optionally chainquery on DigitalOcean.

Alternatively there is the [shell installer](https://github.com/lbryio/lbry-docker/blob/master/chainquery/README.md) that can run on any Ubuntu 18.04-LTS equipped machine to get you up and running with a database seed which can save you loads of time bootstrapping your instance.


#### Currently supported platforms

**X86_64 CPU architecture**
Lbrynet production & compiler, Lbrycrd, Chainqery are currently supported.

**Some arm architectures**
Lbrynet armhf and arm64 compilers

**More will be added on request and over time**

## Usage
You may see above [the installation section above](https://github.com/lbryio/lbry-docker#installation) to obtain container specific instructions.

## Running from source
Running this stuff from source should be possible if you have both [Docker](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/) both installed.  If these are both installed, you can proceed to run the following from within your development directory.
```
git clone https://github.com/lbryio/lbry-docker.git
```
Once you have a local copy of the recent source, you will want to consider what containers/applications you require in your environment.  At the moment since at the writing of this documentation, this comes with an assertion of [YMMV](https://dictionary.cambridge.org/dictionary/english/ymmv) so if something isn't working feel free to make suggestions in the form of a PR for how we should do this better.  The beauty of Open Source is learning better ways to do things as well as contributing to the world, so I'm always going to be welcoming to contributions.

#### From Source for Contributions
Running from source for contributing and Merge/Pull requests.
My goal is to make contributing to this possible using Docker and also GitLab CI/CD time.  

## [Contributing](CONTRIBUTING.md)
Keep in mind [I am](https://github.com/leopere/) preferential to receiving patches over rule-following as we can always nudge you in the right direction to get things more compatible with the project ethos if it's not.  Never be afraid to file a PR no one should be offended.  Having said this following the next two guides will greatly improve the speed at which we can integrate your improvements.
* [Repository Standards]( https://lbry.tech/resources/repository-standards)
* [Contribute](https://lbry.tech/contribute)
* Have an LBC wallet ready as we want you to have some for the help! Hell, why not post it in your Commit or Merge Request for all I care but take your tips!

## Getting Support
Sometimes we just aren't omniscient omnipresent or even omnipotent. So since this is the case despite our constant striving for these goals we're aware that things are imperfect so when you find these imperfections please reach out to us!  You can become a contributor without even knowing how to code a damn thing!  Just open a Git Issue so long as it's not a duplicate its a huge help to us and often times it'll earn you some LBC if you're a part of our community.

#### Creating an Issue
Please be sure to fill out the [issue template](https://github.com/lbryio/lbry-docker/issues/new) as best as possible.  This will help us answer your questions faster and fix things quicker if we have quality reports.


## License
This project is Licensed under the [MIT License](/LICENSE)

## Security
“We take security seriously. Please contact [security@lbry.io](mailto:security@lbry.io) regarding any security issues. Our PGP key is [here](https://keybase.io/lbry/key.asc) if you need it.”  LBRY is built primarily on top of proven technologies however if you find something that might increase the risk of someone losing their crypto currency [Responsible Disclosure](https://en.wikipedia.org/wiki/Responsible_disclosure) is always appreciated, however, that said, we're all open-source here.

## Contact
* The primary contact for this project is @leopere feel free to reach out to **leopere [ at ] nixc [ dot ] us**

## Additional Info and Links
* [Install Docker](https://docs.docker.com/install/)
* [Install docker-compose](https://docs.docker.com/compose/install/)
* [Email to security@lbry.io](mailto:security@lbry.io)
* [security@lbry.io's GPG Key](https://keybase.io/lbry/key.asc)
* [Responsible Disclosure](https://en.wikipedia.org/wiki/Responsible_disclosure)
* [Issue Template](https://github.com/lbryio/lbry-docker/issues/new)
* [Use Issue Search](https://github.com/lbryio/lbry-docker/issues?utf8=%E2%9C%93&q=is%3Aissue)
* [Repository Standards]( https://lbry.tech/resources/repository-standards)
* [Global Contributing Standards](https://lbry.tech/contribute)
* [CONTRIBUTING.md](/CONTRIBUTING.md)
* [Project Status](https://github.com/lbryio/lbry-docker/projects/1)
* [Running from source](##Running-from-source)
* [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
* [RancherOS](https://rancher.com/rancher-os/)
* [Kubernetes](https://kubernetes.io/)
* [Version 1.0 project board](https://github.com/lbryio/lbry-docker/projects/1)
