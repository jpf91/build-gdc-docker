#!/bin/sh
set -ex

wget http://gdcproject.org/downloads/binaries/x86_64-linux-gnu/native_2.065_gcc4.9.0_a8ad6a6678_20140615.tar.xz
wget http://code.dlang.org/files/dub-0.9.22-linux-x86_64.tar.gz
tar xf dub-0.9.22-linux-x86_64.tar.gz
tar xf native_2.065_gcc4.9.0_a8ad6a6678_20140615.tar.xz
git clone https://github.com/D-Programming-GDC/build-gdc.git
cd build-gdc
PATH=$PATH:/home/build/x86_64-gdcproject-linux-gnu/bin ../dub build --compiler=gdc
cp build-gdc ~/shared
