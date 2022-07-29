#!/bin/sh

export LC_ALL=C

BUILD=1-init
echo "${BUILD} start: `date`"    | tee    start-stop.log
echo "${BUILD} start: `date`"    | tee    ${BUILD}.log
/usr/bin/time ./${BUILD}.sh 2>&1 | tee -a ${BUILD}.log
echo "${BUILD} stop: `date`"     | tee -a ${BUILD}.log
echo "${BUILD} stop: `date`"     | tee -a start-stop.log

for BUILD in 2-build-test 3-fetch 4-build-all-cores 5-build-8-bb-threads 6-build-16-bb-threads 7-build-2-bb-threads; do
  rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
  echo "${BUILD} start: `date`"    | tee -a start-stop.log
  echo "${BUILD} start: `date`"    | tee    ${BUILD}.log
  /usr/bin/time ./${BUILD}.sh 2>&1 | tee -a ${BUILD}.log
  echo "${BUILD} stop: `date`"     | tee -a ${BUILD}.log
  echo "${BUILD} stop: `date`"     | tee -a start-stop.log
  grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee ${BUILD}.top20
done

tail -n 5 *.log
