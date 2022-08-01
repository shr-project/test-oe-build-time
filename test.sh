#!/bin/sh

export LC_ALL=C

OUT="${1}"

if [ -z "${OUT}" ] ; then
  BRANCH=`git branch --show-current`
  OUT="results-${BRANCH}"
fi

if [ -d "${OUT}" ] ; then
  echo "ERROR: output directory ${OUT} already exists, aborting to prevent accidentally overwitting the logs there"
  echo "ERROR: delete this directory or set different one with first parameter"
  exit 1
else
  mkdir ${OUT}
fi

BUILD=1-init
echo "${BUILD} start: `date --iso-8601=seconds`"     | tee    ${OUT}/start-stop.log
echo "${BUILD} start: `date --iso-8601=seconds`"     | tee    ${OUT}/${BUILD}.log
/usr/bin/time ./${BUILD}.sh 2>&1  | tee -a ${OUT}/${BUILD}.log
echo "${BUILD} stop:  `date --iso-8601=seconds`"     | tee -a ${OUT}/${BUILD}.log
echo "${BUILD} stop:  `date --iso-8601=seconds`"     | tee -a ${OUT}/start-stop.log

for BUILD in 2-build-test 3-fetch 4-build-all-cores 5-build-8-bb-threads 6-build-16-bb-threads 7-build-2-bb-threads; do
  rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
  echo "${BUILD} start: `date --iso-8601=seconds`"    | tee -a ${OUT}/start-stop.log
  echo "${BUILD} start: `date --iso-8601=seconds`"    | tee    ${OUT}/${BUILD}.log
  /usr/bin/time ./${BUILD}.sh 2>&1 | tee -a ${OUT}/${BUILD}.log
  echo "${BUILD} stop:  `date --iso-8601=seconds`"    | tee -a ${OUT}/${BUILD}.log
  echo "${BUILD} stop:  `date --iso-8601=seconds`"    | tee -a ${OUT}/start-stop.log
  grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee ${OUT}/${BUILD}.top20
  mv poky/build/tmp/buildstats ${OUT}/buildstats-${BUILD}
done

tail -n 5 ${OUT}/*.log
