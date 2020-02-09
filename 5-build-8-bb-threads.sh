#!/bin/sh

cd poky
. ./oe-init-build-env
cat >> conf/local.conf << EOF
BB_NUMBER_THREADS = "8"
PARALLEL_MAKE = "-j \${@oe.utils.cpu_count()}"
EOF

rm -rf bitbake-cookerdaemon.log cache sstate-cache tmp
bitbake -k core-image-sato 2>&1
