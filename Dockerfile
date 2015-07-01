FROM buildpack-deps:wheezy


# Install crosstool/gcc build requirements
# Note: We don't use multiarch support. On wheezy it's broken as it's not possible
# to install the static libstdc++ for 64 and 32 bits. Make sure we have all
# 64 bits libraries and use a self-built cross compiler for 32 bit.
RUN apt-get update && apt-get install -y \
        gcc-multilib \
        g++-multilib \
        gperf \
        bison \
        flex \
        gawk \
        texinfo \
        libtool \
        automake \
        libncurses5-dev \
        xz-utils \
        p7zip \
        bash \
        libstdc++6 \
        libstdc++6-4.7-dev \
        gdb \
        nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Add build user
RUN adduser --disabled-password --gecos "" build \
    && chsh -s /bin/bash build \
    && echo "dash dash/sh boolean false" | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash


#ENV CTNG_SRC https://github.com/crosstool-ng/crosstool-ng/archive/crosstool-ng-1.20.0.tar.gz
#ENV CTNG_SRC https://api.github.com/repos/crosstool-ng/crosstool-ng/tarball/master
# Install CTNG
#RUN mkdir build && cd build \
#    && wget -nv ${CTNG_SRC} -O ctng.tar.gz \
#    && tar xf ctng.tar.gz \
#    && cd crosstool-ng-* \
#    && ./bootstrap \
#    && ./configure --prefix=/usr \
#    && make \
#    && make install \
#    && cd ../../ && rm -rf build


ENV CTNG_REV 46ea24bfd1e3d644cb7b0be54055c3dc47f0e3aa
RUN mkdir build && cd build \
    && git clone https://github.com/jpf91/crosstool-ng.git \
    && cd crosstool-ng \
    && git checkout ${CTNG_REV} \
    && ./bootstrap \
    && ./configure --prefix=/usr \
    && make \
    && make install \
    && cd ../../ && rm -rf build


# Install build-gdc tool
ADD build-gdc /usr/bin/build-gdc
RUN chmod +x /usr/bin/build-gdc
ADD rebuild-build-gdc.sh /home/build/rebuild-build-gdc.sh
RUN chmod +x /home/build/rebuild-build-gdc.sh \
    && chown build:build /home/build/rebuild-build-gdc.sh


# Initialize /home/build directory
WORKDIR /home/build
USER build


# Exact revision doesn't matter, updated at runtime anyway
ENV GDC_SRC https://github.com/D-Programming-GDC/GDC.git
ENV GDC_CFG_SRC https://github.com/D-Programming-GDC/build-gdc-config.git

# force invalidate cache for GDC
ENV GDC_DATE 06062015
# Initialize GDC & build config sources
RUN echo ${GDC_DATE} \
    && git clone ${GDC_SRC} \
    && git clone ${GDC_CFG_SRC} \
    && mkdir shared
