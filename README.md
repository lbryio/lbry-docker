# lbry-Docker

## Scope
This repository is in heavy flux as it travels towards [version 1.0](https://github.com/lbryio/lbry-docker/projects/1) however its goal is to make development for and adoption of any of the LBRY appliances trivial.  You should be able to clone pull fork your way to a better LBRY without having to do much more than some light reading of a README to get started.

#### Documentation is WIP
Currently this repository is a WIP and is under heavy construction, use at your own risk make sure you keep regular backups of your wallets.  Your milage may vary as how far this will work for you be sure to file good and concise issues if you plan to and keep in mind we're allergic to regressions when filing PR's.

#### Goals
This repository aims for [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) minimalism, ephemerality, and statelessness.  It will use well commented **`Shell scripts`**, Dockerfiles, and Docker-Compose which is a template that is a baseline for many other container management services such as [RancherOS](https://rancher.com/rancher-os/) and [Kubernetes](https://kubernetes.io/).

#### Beautiful Screenshot/Gif
Since there is nothing to see here just yet I'll entertain you with the current state of affairs with this repository.
![image](https://spee.ch/855d1958650b850b249b9ee592ba2f4c6fc7eeec/container-unloading-gone-wrong-151175.gif)

## Installation

[This is currently WIP and Not Recommended for Production](https://github.com/lbryio/lbry-docker/projects/1)
See [Running from source](##Running-from-source) for the current instructions on how to use this.

#### Currently supported platforms

**X64 cpu architecture**

**More will be added on request and over time**

## Usage
For now I don't recommend using this container cluster however you're welcomed to [contribute](#contributing) if you feel up to the task.


## Running from source
Running this stuff from source should be possible if you have both [Docker](https://docs.docker.com/install/) and [docker-compose](https://docs.docker.com/compose/install/) both installed.  If these are both installed you can proceed to run the following from within your development directory.
``` git clone https://github.com/lbryio/lbry-docker.git
```
Once you have a local copy of the recent source you will want to consider what containers/applications you require in your environment.  At the moment since at the writing of this documentation this comes with an assertion of [YMMV](https://dictionary.cambridge.org/dictionary/english/ymmv) so if something isn't working feel free to make suggestions in the form of a PR for how we should do this better.  The beauty of Open Source is learning better ways to do things as well as contributing to the world so I'm always going to be welcoming to contributions.

#### From Source for Contributions
Running from source for contributing and Merge/Pull requests.
My goal is to make contributing to this possible using Docker and also GitLab CI/CD time.  

## [Contributing]()
Keep in mind [I am](https://github.com/leopere/) preferential to receiving patches over rule following as we can always nudge you in the right direction to get things more compatible with the project ethos if it's not.  Never be afraid to file a PR no one should be offended.  This said following the next two guides will greatly improve the speed at which we can integrate your improvements.
* [Repository Standards]( https://lbry.tech/resources/repository-standards)
* [Contribute](https://lbry.tech/contribute)
* Have a LBC wallet ready as we want you to have some for the help! Hell why not post it in your Commit or Merge Request for all I care but take your tips!

## Getting Support

#### Debugpaste [WIP]
I'll be including a function to get a self destructing debugpaste of your LBRY appliances logs you'll be able to execute something similar to the following in all containers to export raw logs to a paste service where you can then either modify them removing sensitive data or just take that URL and create a new issue after you [(Use Issue Search)](https://github.com/lbryio/lbry-docker/issues?utf8=%E2%9C%93&q=is%3Aissue) to make sure there isn't already an open thread for your issue.

#### Example debugpaste
```
cd chainquery/
docker-compose exec chainquery debugpaste
https://haste.nixc.us/ocatumatozaq.nginx
```
You can then take output given in the response from the debugpaste command and put that into your github issue (This may be automated at some point to some degree).


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
