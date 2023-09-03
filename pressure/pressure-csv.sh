#!/bin/bash

for D in threadripper-3970x-128gb-gentoo*; do
    for B in 4-build-all-cores 5-build-8-bb-threads 6-build-16-bb-threads 7-build-2-bb-threads; do
        if [ -d ${D}/buildstats-${B} ] ; then
            DD=${D/threadripper-3970x-128gb-gentoo-}
            DATA="${D}/buildstats-${B}/*/reduced_proc_pressure"
            if [ -f ${DATA}/cpu.log ] ; then
                OUT=pressure_${DD}_${B}_all.csv
                echo "Processing ${DATA} to ${OUT}"

                echo "${DD};${B};cpu;;;;io;;;;mem;;;" > ${OUT}
                N=1
                echo "TIME;AVG10;AVG60;AVG300;DIFF;AVG10;AVG60;AVG300;DIFF;AVG10;AVG60;AVG300;DIFF" >> ${OUT}
                cat ${DATA}/cpu.log | while read CPU_TIME; do
                    IO_TIME=$(sed -n ${N}p ${DATA}/io.log)
                    MEM_TIME=$(sed -n ${N}p ${DATA}/memory.log)
                    if [ "${CPU_TIME}" != "${IO_TIME}" ] || [ "${CPU_TIME}" != "${MEM_TIME}" ] ; then
                        echo "Something is wrong in ${DATA} the line ${N}, don't have the same timestamp. CPU: ${CPU_TIME}, IO: ${IO_TIME}, MEM: ${MEM_TIME}"
                    fi

                    let "N++"
                    read CPU_AVG10 CPU_AVG60 CPU_AVG300 CPU_DIFF
                    sed -n ${N}p ${DATA}/io.log | read IO_AVG10 IO_AVG60 IO_AVG300 IO_DIFF
                    sed -n ${N}p ${DATA}/memory.log | read MEM_AVG10 MEM_AVG60 MEM_AVG300 MEM_DIFF

                    let "N++"
                    read BLANK

                    echo "${CPU_TIME};${CPU_AVG10};${CPU_AVG60};${CPU_AVG300};${CPU_DIFF};${IO_AVG10};${IO_AVG60};${IO_AVG300};${IO_DIFF};${MEM_AVG10};${MEM_AVG60};${MEM_AVG300};${MEM_DIFF}" >> ${OUT}
                done
            fi
        fi
    done
done
