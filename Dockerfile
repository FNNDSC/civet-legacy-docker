FROM ubuntu:18.04

ARG ARCH=x86_64

RUN ["apt-get", "update", "-qq"]
RUN ["apt-get", "install", "-qq", "--no-install-recommends", "perl", "imagemagick", "gnuplot-nox", "locales"]

RUN ["apt-get", "install", "-qq", "git-lfs"]

RUN ["apt-get", "install", "-qq", "build-essential", "automake", "libtool", "bison"]
RUN ["apt-get", "install", "-qq", "libz-dev", "libjpeg-dev", "libpng-dev", "libtiff-dev", \
    "liblcms2-dev", "flex", "libx11-dev", "freeglut3-dev", \
    "libxmu-dev", "libxi-dev", "libqt4-dev"]

RUN ["rm", "/bin/sh"]
RUN ["ln", "-s", "/bin/bash", "/bin/sh"]

# use HTTPS instead of SSH for git clone
RUN ["git", "config", "--global", "url.https://github.com/.insteadOf", "git@github.com:"]

COPY . /opt/CIVET
WORKDIR /opt/CIVET
RUN ["git", "lfs", "pull"]

# copy configuration so installation can be non-interactive
RUN mkdir -p Linux-$ARCH/SRC
RUN tar -zxf TGZ/netpbm-10.35.94.tgz -C Linux-$ARCH/SRC/
COPY provision/netpbm/Makefile.config Linux-$ARCH/SRC/netpbm-10.35.94

RUN ["bash", "install.sh"]
RUN ["bash", "job_test"]

# clean up build files to reduce image size
WORKDIR /opt/CIVET/Linux-$ARCH
RUN ["rm", "-r", "SRC", "building", "info", "man"]
RUN ["chmod", "--recursive", "u+rX,g+rX,o+rX", "/opt/CIVET" ]

# init.sh environment variables, should be equivalent to
# printf "%s\n\n" "source /opt/CIVET/Linux-x86_64/init.sh" >> ~/.bashrc
ENV MNIBASEPATH=/opt/CIVET/Linux-$ARCH CIVET=CIVET-2.1.1
ENV PATH=$MNIBASEPATH/$CIVET:$MNIBASEPATH/$CIVET/progs:$MNIBASEPATH/bin:$PATH \
    LD_LIBRARY_PATH=$MNIBASEPATH/lib \
    MNI_DATAPATH=$MNIBASEPATH/share \
    PERL5LIB=$MNIBASEPATH/perl \
    R_LIBS=$MNIBASEPATH/R_LIBS \
    VOLUME_CACHE_THRESHOLD=-1 \
    BRAINVIEW=$MNIBASEPATH/share/brain-view \
    MINC_FORCE_V2=1 \
    MINC_COMPRESS=4 \
    CIVET_JOB_SCHEDULER=DEFAULT

RUN ln -s $MNIBASEPATH/$CIVET/CIVET_Processing_Pipeline /CIVET_Processing_Pipeline
CMD ["/CIVET_Processing_Pipeline", "-help"]
