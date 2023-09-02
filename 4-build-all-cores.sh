#!/bin/sh

# builds with the default value of BB_NUMBER_THREADS and PARALLEL_MAKE as defined in:
# meta/conf/bitbake.conf:BB_NUMBER_THREADS ?= "${@oe.utils.cpu_count()}"
# meta/conf/bitbake.conf:PARALLEL_MAKE ?= "-j ${@oe.utils.cpu_count()}"
# the disadvantage of this default is that on builder with *a lot* of
# threads, when building really big image from scratch (without sstate)
# you can end with *a lot* bitbake threads doing do_compile tasks at the
# same time and each do_compile task spawning *a lot* of compilers
# (e.g. really worse case scenario would be 256 * 256 gcc processes running
# at the same time on your 256 thread dual Epyc)
#
# That's why other tests will lower the BB_NUMBER_THREADS so some sane
# value, so that less tasks run in parallel, but long do_compile tasks
# like qtwebengine build are still using as many threads as possible
# through PARALLEL_MAKE
#
# Will set it in local.conf even when it's the default, just in case you
# need to re-run this script in build directory where some other test
# already set some other values

cd poky
. ./oe-init-build-env
cat >> conf/local.conf << EOF
BB_NUMBER_THREADS = "\${@oe.utils.cpu_count()}"
PARALLEL_MAKE = "-j \${@oe.utils.cpu_count()} -l \${@oe.utils.cpu_count()}"
BB_PRESSURE_MAX_CPU = "100000"
EOF

rm -rf bitbake-cookerdaemon.log cache sstate-cache tmp
bitbake -k core-image-sato 2>&1
