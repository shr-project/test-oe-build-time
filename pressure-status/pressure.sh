# for i in */*log; do grep -q Pressure.status.changed $i && grep Pressure.status.changed $i > pressure-status/$i; done

for i in */*.log; do
    d=`dirname $i`
    dd=`echo $d | sed 's/threadripper-3970x-128gb-gentoo-//g; s/2023-08-with-reg-cpu-pressure-//g; s/-chp-logic-fixes/-fixes/g'`
    f=`basename ${i/.log}`
    ff=`echo $f | sed 's/4-build-all-cores/64-bb/g; s/5-build-8-bb-threads/8-bb/g; s/6-build-16-bb-threads/16-bb/g; s/7-build-2-bb-threads/2-bb/g'`
    sed "s@^NOTE: Pressure status changed to CPU.*CPU: \(.*\)/\(.*\), IO: \(.*\)/\(.*\), Mem: \(.*\)/\(.*\))\( - using \([0-9]*\)/\([0-9]*\) bitbake threads\|$\)*@$dd-$ff;\1;\3;\5;\8@g" $i > $d/$f.csv
done
