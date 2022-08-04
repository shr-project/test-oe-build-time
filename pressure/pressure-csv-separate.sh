#!/bin/sh

# threadripper-3970x-128gb-gentoo-dunfell-2022-07
# threadripper-3970x-128gb-gentoo-kirkstone-2022-07
# threadripper-3970x-128gb-gentoo-langdale-2022-07
# threadripper-3970x-128gb-gentoo-langdale-2022-07-with-dash-l
# threadripper-3970x-128gb-gentoo-langdale-2022-07-with-reg-cpu-pressure
# threadripper-3970x-128gb-gentoo-langdale-2022-07-with-reg-cpu-pressure-no-dash-l
# threadripper-3970x-128gb-gentoo-langdale-2022-07-with-reg-cpu-pressure-no-swap

for D in threadripper-3970x-128gb-gentoo*; do
    DD=${D/threadripper-3970x-128gb-gentoo-}
    DD=${DD/-2022-07}

    # Keep the filenames (sheet names) short
    DD=${DD/dunfell/D}
    DD=${DD/kirkstone/K}
    DD=${DD/langdale/L}
    DD=${DD/-with-reg-cpu-pressure-no-dash-l/-reg-noswap}
    DD=${DD/-with-reg-cpu-pressure-no-swap/-reg-l-noswap}
    DD=${DD/-with-reg-cpu-pressure/-reg-l}
    DD=${DD/-with-dash-l/-l}

    for B in 4-build-all-cores 5-build-8-bb-threads 6-build-16-bb-threads 7-build-2-bb-threads; do
        BB=${B/-bb-threads}
        BB=${BB/4-build-}
        BB=${BB/5-build-}
        BB=${BB/6-build-}
        BB=${BB/7-build-}
        BB=${BB/all-cores/64}

        if [ -d ${D}/buildstats-${B} ] ; then
            for P in memory cpu io; do
                PP=${P/memory/mem}
                DATA="${D}/buildstats-${B}/*/reduced_proc_pressure/${P}.log"
                if [ -f ${DATA} ] ; then
                    OUT=pressure/${DD}_${BB}_${PP}.csv
                    echo "Processing ${DATA} to ${OUT}"

                    echo "${DD};${BB};${PP};;;${D};${B}" > ${OUT}
                    echo "TIME;AVG10;AVG60;AVG300;DIFF" >> ${OUT}
                    cat ${DATA} | while read TIME; do
                        read AVG10 AVG60 AVG300 DIFF; read BLANK
                        echo "${TIME};${AVG10};${AVG60};${AVG300};${DIFF}" >> ${OUT}
                    done
                fi
            done
        fi
    done
done
