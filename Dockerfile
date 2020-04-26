FROM ubuntu:18.04

ARG ARCH=x86_64

RUN ["apt-get", "update", "-qq"]
RUN ["apt-get", "install", "-qq", "--no-install-recommends", "perl", "imagemagick", "gnuplot-nox", "locales"]

RUN ["rm", "/bin/sh"]
RUN ["ln", "-s", "/bin/bash", "/bin/sh"]

COPY dist /opt/CIVET

WORKDIR /opt/CIVET/Linux-$ARCH

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
