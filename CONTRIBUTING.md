# Contributing
“This project follows the global contributing standards for all LBRY projects, to read those go [https://lbry.tech/resources/repository-standards](https://lbry.tech/resources/repository-standards). Also to [https://lbry.tech/contribute](https://lbry.tech/contribute).

## Table of Contents
<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Contributing](#contributing)
	- [Table of Contents](#table-of-contents)
	- [Important things to Note](#important-things-to-note)
			- [Two core versions of Linux as base](#two-core-versions-of-linux-as-base)
	- [Consistency across containers](#consistency-across-containers)
	- [Note to contributors](#note-to-contributors)
	- [Code Overview](#code-overview)
			- [Dockerfiles](#dockerfiles)
			- [docker-compose.yml](#docker-composeyml)
			- [Debugpaste-it.sh](#debugpaste-itsh)
			- [.env](#env)
			- [start.sh](#startsh)
			- [docker-entrypoint.sh](#docker-entrypointsh)
			- [Multi Stage Containers](#multi-stage-containers)
			- [Traefik](#traefik)
				- [traefik/traefik.toml](#traefiktraefiktoml)
			- [reflector.go/config.tmpl [Documentation of this is WIP]](#reflectorgoconfigtmpl-documentation-of-this-is-wip)
			- [Data directories](#data-directories)
			- [Compile containers [WIP]](#compile-containers-wip)
			- [Configuration Order of Precedence](#configuration-order-of-precedence)
	- [Testing](#testing)
	- [Submitting Pull Requests](#submitting-pull-requests)

<!-- /TOC -->

## Important things to Note

#### Two core versions of Linux as base
We want to keep this as simple and as uniform as possible so try to stick to either:
* **`Ubuntu 18.04`** or whatever is the latest version of [Ubuntu LTS](https://wiki.ubuntu.com/LTS) is.
* [Alpine Linux](https://alpinelinux.org/) as this is the smallest and most active container base.

## Consistency across containers
Its extremely important for usability that we work within reasonably confines of a stable core set of functions.  Things that should be simple and available in all containers.
* Simple method to extract consistent and informative logging information for ease of obtaining support.
* [Principle of Least Privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege) the main process should be running in an unprivileged user and have little to no influence on the surrounding container.  If this means writing App Armor profiles then so be it.  Ideally a 1.0 release will come out with just an underprivileged user.
* One process per container, I realize that this is only a docker best practices guideline but I think that it's important to adhere to, not only for security but for flexibility for others to work on top of our containers.

## Note to contributors
Keep in mind [I am](https://github.com/leopere/) preferential to receiving patches over rule following as we can always nudge you in the right direction to get things more compatible with the project ethos if it's not.  Never be afraid to file a PR no one should be offended.  This said following the next two guides will greatly improve the speed at which we can integrate your improvements.
* [Repository Standards]( https://lbry.tech/resources/repository-standards)
* [Contribute](https://lbry.tech/contribute)
* Have a LBC wallet ready as we want you to have some for the help! Hell why not post it in your Commit or Merge Request for all I care but take your tips!
* Sanitize your secrets, if you set an environment variable inside of a container using an Environment Variable you should consider nullifying the variable once it's been used.  Ideally before you open communications out to the internet.

## Code Overview
#### Dockerfiles
These files should be usage case specific and leading to a release container only at the moment.  There may be the odd container that will compile from source such as [Reflector.go](/Reflector.go/README.md) but the release containers will ideally build against the latest binary releases exclusively.

#### docker-compose.yml
These files will ideally be templates that you can override in your own environment using docker-compose.override.yml this should allow people to grab a copy and run with the repo in hand with relative ease.  Eventually we will need to have a docker-compose.yml that will `pull` from precompiled containers rather than `build` to help people save space and time but in pre 1.0 status of a container or the project itself it will need to be `build`.

#### Debugpaste-it.sh
Debugpaste-it.sh will have any appliance specific abstractions in place to help obtain and pipe the logs to a pastebin of some kind.  Currently the idea is to use something like https://github.com/nixc-us/debugpaste-it to get the log files to a place that can exist that by default self destructs for the end users privacy after a period of time.  The way HasteBin works is the latest page load resets the expiry timer of the paste.  This plus a 90 day expiration on the server it's hosted on should be more than enough time to keep relevant data available for fixes to be rolled out.  This is not a required URL but it is a way to export the log data so the end user can go through their due diligence.

This will likely be much more dynamic internally than the actual GoLang binary for `debugpaste-it` as debugpaste-it should only change if the HasteBin server it's pointed at changes.

#### .env
dot env files are an option that users can employ to insert environment variables into the containers, sometimes certain variables can be defined twice and rather than doing anything twice it's better to use an .env file.  

For example in [Chainquery](../chainquery/docker-compose.yml) you will have a relational database such as a `MySQL` container which will have environment variables for both the Database(MySQL) and Chainquery's container configuration.

#### start.sh
Start.sh will be required in some cases to ensure that configurations are implemented on top of any changes the end user might add by way of installing their own Config files.  This way you can still insert environment variables by way of the `.env`, `docker-compose.yml` and the `docker-compose.override.yml` files.

#### docker-entrypoint.sh
docker-entrypoint.sh is executed prior to anyone running `docker exec {ContainerName}` or `docker-compose exec {ContainerName}` I've included some of these as blank files for now however as these containers develop there may be usage cases for them that arise.  One of the things that could be passed to `docker-entrypoint` is a call for `debugpaste-it` depending on how the appliance functions it may be prudent for either the `docker-entrypoint` or `debugpaste-it` to signal to the appliance to dump its logs somewhere it can be read by the paste bin application for review and sanitization prior to issue submission.

#### Multi Stage Containers
Multi stage containers is a relatively new feature of Docker however arguably a critical one.  Ideally to avoid having any unnecessary additional software inside of the containers you can and should employ a separate build phase for any source building.

#### Traefik
This will be some reverse proxy boilerplate for people to draw from as either an example or as a shippable front end reverse proxy.  The goal is to have a fully deployable and secured as best as possible container cluster out of the box.  We want people to be able to kick the tires on these appliances shortly after a git clone.  As it exists currently there are a few variables that would need to be changed to get started.  I may rework this to reduce the number of steps towards success.

Your certificates will be stored within the `{gitRepositoryRoot}/traefik/data/acme.json` you can delete these and Træfik will re-provision them however keep in mind you may hit a weekly [issuance limit](https://letsencrypt.org/docs/rate-limits/) with Lets Encrypt.

##### traefik/traefik.toml
Default configuration of Træfik is to setup TLS certificates for any properly routed DNS records defined in docker-compose.yml and your DNS provider's zone files.
This file requires two modifications the administration email address needs to be one that you can receive notification of certificate expiry in the case wherein Træfik stops maintaining your TLS certificates for some reason indicating an issue with your setup.  Also the root domain where your cluster will be residing behind.  This requires that you have a domain you can point at your cluster.  There are many free options such as https://www.tk domains and Dynamic DNS providers.  There are many great options to get you off the ground.

#### reflector.go/config.tmpl [Documentation of this is WIP]
This config.tmpl should be the boilerplate to get a configuration up and running.  There may end up being more depending on how this container matures over time.

#### Data directories
These are created within the Git Repository path as a baseline configuration you're encouraged to switch things up to match your deployment or dev environment.  However, these directories being contained within this location means that your whole setup is portable and self contained.  It shouldn't mess with the host Operating System and I'd like to keep it this way.

These `./data/` directories should be ignored by the repository included `.gitignore`'s. so a git pull should not delete them however prior to a [1.0 release](https://github.com/lbryio/lbry-docker/milestone/1) of these containers it is not something I would bank on.

#### Compile containers [WIP]
These containers should be able to compile against any commit of any branch in any of the lbryio repositories that the containers apply to.
They need to be able to run linting, unit tests, and build steps.  They should result in a binary that could be effectively interchangeable with the release Dockerfiles

#### Configuration Order of Precedence
1. docker run and docker-compose file parameters should overwrite everything.
2. configuration files should be accepted and added to when the container is instantiated.
3. secret sanitization should occur after the previous two.

## Testing
Currently the testing suite will be considered under development however if you understand what's going on currently without much explanation I'd gladly take PR's this said I'm not averse to explanation but if you want to jump right in, I'm all for that too!

## Submitting Pull Requests
[https://help.github.com/articles/about-pull-requests/](https://help.github.com/articles/about-pull-requests/)
