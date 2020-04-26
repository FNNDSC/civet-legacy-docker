# CIVET Multi-Arch

An attempt to compile [CIVET](http://www.bic.mni.mcgill.ca/ServicesSoftware/CIVET) in Docker on non-x86_64 hosts.

Please see the upstream repository: https://github.com/aces/CIVET_Full_Project

An image for PowerPC x64 is available: https://hub.docker.com/r/fnndsc/civet_moc_ppc64

## Objective

Software support on the Mass Open Cloud imposes these limitations:

- architecture is ppc64le (IBM Power9)
- no [Docker multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) (outdated Docker version required by OpenShift)

## Changes

`config.guess` (2008) was updated to 2020-01-01.

## Development

Run `builder.sh`

```
usage: ./builder.sh [-r] [TAG]

Compile CIVET in a docker container on a non-x86_64 host
without support for Docker multi-stage builds.

Binaries will be copied to /mnt/wdext/acelab2018/CIVET_Full_Project/dist

options:
-h     show this help message and exit
-r     remove the builder image
-d     remove the binaries
-t     run test job
[TAG]  image name [default: fnndsc/civet_moc_ppc64:2.1.1]
```
