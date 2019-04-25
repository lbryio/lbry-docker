# lbrynet

## Compiler container

The [Dockerfile-compiler-linux](Dockerfile-compiler-linux) is for building lbrynet for any architecture supported
by an Ubuntu 18.04 base image.

### Register qemu to run docker images built for platforms other than your host

```
docker run --rm --privileged multiarch/qemu-user-static:register
```

### Build for the default x86_64 platform:

```
docker build -t lbrynet -f Dockerfile-compiler-linux .
```

### Build for an ARM 32-bit platform:

```
docker build -t lbrynet-armhf -f Dockerfile-compiler-linux --build-arg BASE_IMAGE=multiarch/ubuntu-core:armhf-bionic .
```

### Build for an ARM 64-bit platform:

```
docker build -t lbrynet-arm64 -f Dockerfile-compiler-linux --build-arg BASE_IMAGE=multiarch/ubuntu-core:arm64-bionic .
```
