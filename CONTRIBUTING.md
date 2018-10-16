# Contributing
“This project follows the global contributing standards for all LBRY projects, to read those go [https://lbry.tech/resources/repository-standards](https://lbry.tech/resources/repository-standards). Also to [https://lbry.tech/contribute](https://lbry.tech/contribute).


## Note to contributors
Keep in mind [I am](https://github.com/leopere/) preferential to receiving patches over rule following as we can always nudge you in the right direction to get things more compatible with the project ethos if it's not.  Never be afraid to file a PR no one should be offended.  This said following the next two guides will greatly improve the speed at which we can integrate your improvements.
* [Repository Standards]( https://lbry.tech/resources/repository-standards)
* [Contribute](https://lbry.tech/contribute)
* Have a LBC wallet ready as we want you to have some for the help! Hell why not post it in your Commit or Merge Request for all I care but take your tips!

## Code Overview
* Dockerfiles - should be usage case specific and leading to a release container only at the moment.  There may be the odd container that will compile from source such as [Reflector.go](/Reflector.go/README.md) but the release containers will ideally build against the latest binary releases exclusively.

* docker-compose.yml files will ideally be templates that you can override in your own environment using docker-compose.override.yml this should allow people to grab a copy and run with the repo in hand with relative ease.  Eventually we will need to have a docker-compose.yml that will `pull` from precompiled containers rather than `build` to help people save space and time but in pre 1.0 status of a container or the project itself it will need to be `build`.

## Testing
Currently the testing suite will be considered under development however if you understand what's going on currently without much explanation I'd gladly take PR's this said I'm not averse to explanation but if you want to jump right in, I'm all for that too!

## Submitting Pull Requests
[https://help.github.com/articles/about-pull-requests/](https://help.github.com/articles/about-pull-requests/)
