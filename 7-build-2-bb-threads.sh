#!/bin/sh

# Build for low RAM (16GB) build on Ryzen 5 1600AF, so that it doesn't
# end in swap for almost whole build time (too many threads for too little RAM).

cd poky
. ./oe-init-build-env
cat >> conf/local.conf << EOF
BB_NUMBER_THREADS = "2"
PARALLEL_MAKE = "-j \${@oe.utils.cpu_count()}"
EOF

rm -rf bitbake-cookerdaemon.log cache sstate-cache tmp
bitbake -k core-image-sato 2>&1
