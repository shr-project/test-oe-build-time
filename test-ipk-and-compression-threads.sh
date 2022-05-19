#!/bin/sh

export LC_ALL=C

for BUILD in 5-build-8-bb-threads; do
  rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
  cat >> poky/build/conf/local.conf << EOF
PACKAGE_CLASSES = "package_ipk"
EOF
  echo "${BUILD} ipk start: `date`" | tee -a start-stop.log
  date > ${BUILD}.log
  /usr/bin/time ./${BUILD}.sh 2>&1 | tee ${BUILD}.log
  echo "${BUILD} ipk stop: `date`" | tee -a start-stop.log
  grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee ${BUILD}.top20

  mkdir threadripper-3970x-128gb-gentoo-langdale-2022-05-ipk
  mv ${BUILD}.log start-stop.log ${BUILD}.top20 threadripper-3970x-128gb-gentoo-langdale-2022-05-ipk

  sed '/^PACKAGE_CLASSES = "package_ipk"$/d' -i poky/build/conf/local.conf

##############################

  rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
  cat >> poky/build/conf/local.conf << EOF
ZSTD_THREADS = "32"
XZ_THREADS = "32"
EOF
  echo "${BUILD} zstd-threads start: `date`" | tee -a start-stop.log
  date > ${BUILD}.log
  /usr/bin/time ./${BUILD}.sh 2>&1 | tee ${BUILD}.log
  echo "${BUILD} zstd-threads stop: `date`" | tee -a start-stop.log
  grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee ${BUILD}.top20

  mkdir threadripper-3970x-128gb-gentoo-langdale-2022-05-zstd-threads
  mv ${BUILD}.log start-stop.log ${BUILD}.top20 threadripper-3970x-128gb-gentoo-langdale-2022-05-zstd-threads

  sed '/ZSTD_THREADS = "32"/d' -i poky/build/conf/local.conf
  sed '/XZ_THREADS = "32"/d' -i poky/build/conf/local.conf

##############################

  rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
  cat >> poky/build/conf/local.conf << EOF
DISTRO_FEATURES:append = " ld-is-gold"
EOF
  echo "${BUILD} ld-is-gold start: `date`" | tee -a start-stop.log
  date > ${BUILD}.log
  /usr/bin/time ./${BUILD}.sh 2>&1 | tee ${BUILD}.log
  echo "${BUILD} ld-is-gold stop: `date`" | tee -a start-stop.log
  grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee ${BUILD}.top20
  grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tee ${BUILD}.task-times

  mkdir threadripper-3970x-128gb-gentoo-langdale-2022-05-ld-is-gold
  mv ${BUILD}.log start-stop.log ${BUILD}.top20 ${BUILD}.task-times threadripper-3970x-128gb-gentoo-langdale-2022-05-ld-is-gold

  sed '/DISTRO_FEATURES:append = " ld-is-gold"/d' -i poky/build/conf/local.conf

##############################

  rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
  cd poky
  git am ../0001-fetch2-use-XZ_DEFAULTS-and-ZSTD_THREADS-variables-in.patch
  cd ..

  echo "${BUILD} unpack-threads start: `date`" | tee -a start-stop.log
  date > ${BUILD}.log
  /usr/bin/time ./${BUILD}.sh 2>&1 | tee ${BUILD}.log
  echo "${BUILD} unpack-threads stop: `date`" | tee -a start-stop.log
  grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tail -n 20 | tee ${BUILD}.top20
  grep -R "Elapsed time" poky/build/tmp/buildstats | sed 's/^.*\/\([^\/]*\/[^\/]*\):Elapsed time: \(.*\)$/\2 \1/g' | sort -n | tee ${BUILD}.task-times

  mkdir threadripper-3970x-128gb-gentoo-langdale-2022-05-unpack-threads
  mv ${BUILD}.log start-stop.log ${BUILD}.top20 ${BUILD}.task-times threadripper-3970x-128gb-gentoo-langdale-2022-05-unpack-threads
done

tail -n 5 *.log
