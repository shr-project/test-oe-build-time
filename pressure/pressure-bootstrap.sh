#!/bin/sh

D="threadripper-3970x-128gb-gentoo-langdale-2022-07-with-reg-cpu-pressure-no-dash-l"
PY="python3 /OE/layers/openembedded-core/scripts/pybootchartgui/pybootchartgui.py"
for B in 4-build-all-cores 5-build-8-bb-threads 6-build-16-bb-threads 7-build-2-bb-threads; do
    if [ -d ${D}/buildstats-${B} ] ; then
        $PY -M -m 60 ${D}/buildstats-${B}/ -f svg -o ${D} | grep -v bootchart > ${D}/${B}.bootchart.pressure-only.txt
        mv ${D}/bootchart.svg ${D}/${B}.bootchart.pressure-only.svg
    else
        echo "${D}/buildstats-${B} doesn't exist, skipping"
    fi
done
