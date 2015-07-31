FROM buildpack-deps:wheezy

# Set root password to root. Useful when debugging this container to install new packages
RUN echo "root:root" | chpasswd

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
        p7zip-full \
        bash \
        libstdc++6 \
        libstdc++6-4.7-dev \
        gdb \
        nano \
        apt-src \
        scons \
        gzip \
        perl \
        autoconf \
        m4 \
        gettext \
        dejagnu \
        expect \
        tcl \
        autogen \
        guile-1.6 \
        flip \
        tofrodos \
        libgmp3-dev \
        libmpfr-dev \
        debhelper \
        texlive \
        texlive-extra-utils \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Add build user
RUN adduser --disabled-password --gecos "" build \
    && echo "build:build" | chpasswd \
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

# force invalidate cache for BUILD_GDC
ENV BUILD_GDC_DATE 15072015
# Install build-gdc tool
RUN mkdir build && cd build \
    && echo $BUILD_GDC_DATE \
    && wget --no-verbose http://gdcproject.org/downloads/binaries/x86_64-linux-gnu/native_2.065_gcc4.9.0_a8ad6a6678_20140615.tar.xz \
    && wget --no-verbose http://code.dlang.org/files/dub-0.9.22-linux-x86_64.tar.gz \
    && tar xf dub-0.9.22-linux-x86_64.tar.gz \
    && tar xf native_2.065_gcc4.9.0_a8ad6a6678_20140615.tar.xz \
    && git clone https://github.com/D-Programming-GDC/build-gdc.git \
    && cd build-gdc \
    && PATH=$PATH:/build/x86_64-gdcproject-linux-gnu/bin ../dub build --compiler=gdc \
    && cp build-gdc /usr/bin/build-gdc \
    && cd ../../ && rm -rf build \
    && rm -rf /root/.dub \
    && rm -f /tmp/dub_platform_probe.d /tmp/dub_platform_probe


# Initialize /home/build directory
WORKDIR /home/build
USER build


# Exact revision doesn't matter, updated at runtime anyway
ENV GDC_SRC https://github.com/D-Programming-GDC/GDC.git
ENV GDC_CFG_SRC https://github.com/D-Programming-GDC/build-gdc-config.git
ENV GDC_WEB_SRC https://github.com/D-Programming-GDC/gdcproject.git

# force invalidate cache for GDC
ENV GDC_DATE 06062015
# Initialize GDC & build config sources
RUN echo ${GDC_DATE} \
    && git clone ${GDC_SRC} \
    && git clone ${GDC_CFG_SRC} \
    && git clone ${GDC_WEB_SRC} \
    && mkdir shared
