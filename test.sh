#!/bin/sh

/usr/bin/time ./1-init.sh 2>&1 | tee 1-init.log

rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
/usr/bin/time ./2-build-test.sh 2>&1 | tee 2-build-test.log
grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee 2-build-test.top20

rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
/usr/bin/time ./3-fetch.sh 2>&1 | tee 3-fetch.log
grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee 3-fetch.top20

rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
/usr/bin/time ./4-build-all-cores.sh 2>&1 | tee 4-build-all-cores.log
grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee 4-build-all-cores.top20

rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
/usr/bin/time ./5-build-8-bb-threads.sh 2>&1 | tee 5-build-8-bb-threads.log
grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee 5-build-8-bb-threads.top20

rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
/usr/bin/time ./6-build-16-bb-threads.sh 2>&1 | tee 6-build-16-bb-threads.log
grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee 6-build-16-bb-threads.top20

tail -n 5 *.log
