#!/bin/bash
git clone https://github.com/D-Programming-GDC/build-gdc.git
cd build-gdc
dub build --compiler=/home/build/host-gdc/x86_64-linux-gnu/bin/x86_64-linux-gnu-gdc

