# lbrynet

## Compiler containers

The compiler containers are for building lbrynet for multiple architectures.

### Build x86 compiler container

```
docker build -t lbrynet-x86_64 -f Dockerfile-x86_64-compiler .
```

### Build ARM compiler container

```
docker build -t lbrynet-armhf -f Dockerfile-armhf-compiler .
```
