#!/bin/sh

GB=128
TH=64

echo "$ mbw -n 5 \`expr ${GB} \* 1024\`" > mbw.txt
mbw -n 5 `expr ${GB} \* 1024` >> mbw.txt
echo "$ sysbench memory --memory-block-size=1K --memory-total-size=${GB}G --threads=1 run" > sysbench-1K-1T.txt
sysbench memory --memory-block-size=1K --memory-total-size=${GB}G --threads=1 run >> sysbench-1K-1T.txt
echo "$ sysbench memory --memory-block-size=1M --memory-total-size=${GB}G --threads=1 run" > sysbench-1M-1T.txt
sysbench memory --memory-block-size=1M --memory-total-size=${GB}G --threads=1 run >> sysbench-1M-1T.txt
echo "$ sysbench memory --memory-block-size=1K --memory-total-size=${GB}G --threads=${TH} run" > sysbench-1K.txt
sysbench memory --memory-block-size=1K --memory-total-size=${GB}G --threads=${TH} run >> sysbench-1K.txt
echo "$ sysbench memory --memory-block-size=1M --memory-total-size=${GB}G --threads=${TH} run" > sysbench-1M.txt
sysbench memory --memory-block-size=1M --memory-total-size=${GB}G --threads=${TH} run >> sysbench-1M.txt
