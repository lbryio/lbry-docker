# x86_64-compiler

This container's goal is to make CI/CD easier for everyone, Travis CI, GitlabCI, Jenkins... Your desktop's docker equipped development environment.

## Example Usage

#### build the x86_64 bin
* `docker build --tag lbryio/lbrynet:x86_64-compiler .`

#### export compiled bin to local /target
This containers sole purpose is to build and spit out the x86_64 binary.
* `docker run --rm -ti -v $(pwd)/target:/target lbryio/lbrynet:x86_64-compiler`
