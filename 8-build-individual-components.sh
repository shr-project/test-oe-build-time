#!/bin/sh

# Run just do_compile task to minimize the amount of RAM used by
# other tasks running in parallel, so that 3990x with 128G RAM doesn't
# end swapping

export LC_ALL=C

THREADS=`cat /proc/cpuinfo  | grep ^processor | wc -l`
COMPONENTS="qtbase qtdeclarative qtwebengine rust-native chromium-x11 nodejs"

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
    echo "8-build-individual-components.${THREADS}.$i start: `date`" | tee -a ../../start-stop.log
    /usr/bin/time -f "$TIME_STR" bitbake -c compile $i 2>&1 | tee ../../8-build-individual-components.${THREADS}.$i.log
    echo "8-build-individual-components.${THREADS}.$i stop: `date`" | tee -a ../../start-stop.log
done

THREADS=`expr ${THREADS} / 2`
cat >> conf/local.conf << EOF
BB_NUMBER_THREADS = "8"
PARALLEL_MAKE = "-j ${THREADS}"
EOF

for i in ${COMPONENTS}; do
    bitbake -c cleansstate $i;
    bitbake -c configure $i;
    echo "8-build-individual-components.${THREADS}.$i start: `date`" | tee -a ../../start-stop.log
    /usr/bin/time -f "$TIME_STR" bitbake -c compile $i 2>&1 | tee ../../8-build-individual-components.${THREADS}.$i.log
    echo "8-build-individual-components.${THREADS}.$i stop: `date`" | tee -a ../../start-stop.log
done

# And this one might be interesting for 3990x with just 96 instead
# of full 128 threads (if it still fits in 128G ram) to use more than
# 64 threads shown in 3970x tests
THREADS=`cat /proc/cpuinfo  | grep ^processor | wc -l`
THREADS=`expr ${THREADS} - ${THREADS} / 4`
cat >> conf/local.conf << EOF
BB_NUMBER_THREADS = "8"
PARALLEL_MAKE = "-j ${THREADS}"
EOF

for i in ${COMPONENTS}; do
    bitbake -c cleansstate $i;
    bitbake -c configure $i;
    echo "8-build-individual-components.${THREADS}.$i start: `date`" | tee -a ../../start-stop.log
    /usr/bin/time -f "$TIME_STR" bitbake -c compile $i 2>&1 | tee ../../8-build-individual-components.${THREADS}.$i.log
    echo "8-build-individual-components.${THREADS}.$i stop: `date`" | tee -a ../../start-stop.log
done
