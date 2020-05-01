#!/bin/sh

# Run just do_compile task to minimize the amount of RAM used by
# other tasks running in parallel, so that 3990x with 128G RAM doesn't
# end swapping

THREADS=`cat /proc/cpuinfo  | grep ^processor | wc -l`
COMPONENTS="qtbase qtdeclarative qtwebengine rust-native chromium-x11"

cd poky
. ./oe-init-build-env
cat >> conf/local.conf << EOF
BB_NUMBER_THREADS = "8"
PARALLEL_MAKE = "-j ${THREADS}"
EOF

rm -rf bitbake-cookerdaemon.log cache tmp/*

export TIME_STR="TIME: %e %S %U %P %c %w %R %F %M %x %C"
for i in ${COMPONENTS}; do
    bitbake -c cleansstate $i;
    bitbake -c configure $i;
    /usr/bin/time -f "$TIME_STR" bitbake -c compile $i 2>&1 | tee ../../8-build-individual-components.${THREADS}.$i.log
done

THREADS=`expr ${THREADS} / 2`
cat >> conf/local.conf << EOF
BB_NUMBER_THREADS = "8"
PARALLEL_MAKE = "-j ${THREADS}"
EOF

for i in ${COMPONENTS}; do
    bitbake -c cleansstate $i;
    bitbake -c configure $i;
    /usr/bin/time -f "$TIME_STR" bitbake -c compile $i 2>&1 | tee ../../8-build-individual-components.${THREADS}.$i.log
done
