# lbrynet
# Docker image tags
`lbry/lbrycrd`
`[linux-x86_64-production](https://github.com/lbryio/lbry-docker/blob/master/chainquery/Dockerfile-linux-x86_64-production)` (Latest release)

## Compiler container

The [Dockerfile-linux-multiarch-compiler](Dockerfile-linux-multiarch-compiler) is for building lbrynet for any architecture supported
by an Ubuntu 18.04 base image.

### Register qemu to run docker images built for platforms other than your host

```
docker run --rm --privileged multiarch/qemu-user-static:register
```

### Build for the default x86_64 platform:

```
docker build -t lbrynet -f Dockerfile-linux-multiarch-compiler .
```

### Build for an ARM 32-bit platform:

```
docker build -t lbrynet-armhf -f Dockerfile-linux-multiarch-compiler --build-arg BASE_IMAGE=multiarch/ubuntu-core:armhf-bionic .
```

### Build for an ARM 64-bit platform:

```
docker build -t lbrynet-arm64 -f Dockerfile-linux-multiarch-compiler --build-arg BASE_IMAGE=multiarch/ubuntu-core:arm64-bionic .
```

### Extra build arguments

#### VERSION

Compile any version of lbrynet by specifying the git tag:

VERSION can be any git reference. Examples:
 
 * master
 * v0.37.2
 * 588568752b983f46f8f492d4bd5d76feeb74dfbf

```
docker build -t lbrynet:v0.36.0 --build-arg VERSION=v0.36.0 -f Dockerfile-linux-multiarch-compiler .
```

### REPO

Compile from any fork of lbrynet:

```
docker build -t lbrynet:v0.37.2-enigmacurry --build-arg VERSION=v0.37.2 \
   --build-arg REPO=https://github.com/EnigmaCurry/lbry.git -f Dockerfile-linux-multiarch-compiler .
```

### Running from the compiler container directly

The container requires a home directory to be mounted at `/home/lbrynet`. This
is to ensure that the wallet is backed up to a real storage device. You must run
the container with the appropriate volume argument, or else lbrynet will refuse
to run.

The config file must be mounted at `/etc/lbry/daemon_settings.yml`.

If you compiled lbrynet as above, with the tag `lbrynet:v0.37.2`, you could run
docker like so:

```
docker run --rm -it -v wallet:/home/lbrynet -v /path/to/daemon_settings.yml:/etc/lbry/daemon_settings.yml lbrynet:v0.37.2 lbrynet start
```

This automatically creates a docker volume called `wallet` and it will persist
across container restarts. See more in the [Docker volume
documentation](https://docs.docker.com/storage/volumes/)

If you would rather not use a docker volume, you can mount a directory 
from your host instead:

```
docker run --rm -it -v /path/on/your/host:/home/lbrynet -v /path/to/daemon_settings.yml:/etc/lbry/daemon_settings.yml lbrynet:v0.37.2 lbrynet start
```

Either way, the container uses the configuration from `/home/lbrynet` inside the container.

