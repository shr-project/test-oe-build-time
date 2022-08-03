#!/bin/sh

cd poky
. ./oe-init-build-env
cat >> conf/local.conf << EOF
BB_NUMBER_THREADS = "8"
PARALLEL_MAKE = "-j \${@oe.utils.cpu_count()} -l \${@oe.utils.cpu_count()}"
BB_PRESSURE_MAX_CPU = "1000"
EOF

rm -rf bitbake-cookerdaemon.log cache sstate-cache tmp
bitbake -k core-image-sato 2>&1
