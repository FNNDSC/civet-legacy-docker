#!/bin/bash -e

dist=$PWD/dist
arch=$(uname -m)

function show_help () {
  cat << EOF
usage: $0 [-r] [TAG]

Compile CIVET in a docker container on a non-x86_64 host
without support for Docker multi-stage builds.

Binaries will be copied to $dist

options:
  -h     show this help message and exit
  -r     remove the builder image
  -d     remove the binaries
  -t     run test job
  [TAG]  image name [default: fnndsc/civet_moc_ppc64:2.1.1]
EOF
}

while getopts ":hrdt" opt; do
  case $opt in
  h   ) show_help && exit 0 ;;
  r   ) remove_builder=1    ;;
  d   ) remove_binaries=1   ;;
  t   ) run_test=1          ;;
  \?  ) echo "Invalid option: -$OPTARG\nRun $0 -h for help."
    exit 1 ;;
  esac
done
shift $((OPTIND-1))

tag=${1:-fnndsc/civet_moc_ppc64:2.1.1}

if [ -d "$dist" ]; then
  # delete the folder before building to minimize build context
  rm -rf "$dist"
fi

# 1. compile binaries in a container
docker build -t civet:builder --build-arg ARCH=$arch -f Dockerfile.builder $PWD

# 1.5 run test job in builder (optional)
if [ -n "$run_test" ]; then
  docker run --rm civet:builder /bin/sh /opt/CIVET/job_test || exit $?
fi

# 2. copy binaries to host
mkdir -p "$dist/Linux-$arch"

# list of folders and files to copy over from the builder
# don't copy everything, the SRC folder is 6 GB of useless stuff!
copy_whitelist="{CIVET-2.1.1,bin,etc,include,init.csh,init.sh,lib,man,perl,share}"

docker run --rm -v "$dist:/dist:z" civet:builder /bin/bash -c \
  "cp -r /opt/CIVET/Linux-$arch/$copy_whitelist /dist/Linux-$arch \
  && chown -R $(id -u):$(id -g) /dist"

# 2.5 delete builder image
if [ -n "$remove_builder" ]; then
  docker rmi civet:builder
fi

# 3. build slim container
docker build -t $tag --build-arg ARCH=$arch $PWD
