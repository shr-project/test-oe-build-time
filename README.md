# test-oe-build-time

Tests build time on non-trivial OE build.

Uses hardcoded git revisions of each layer, to make it reproducible.
The baseline is latest revision in Yocto 3.1 Dunfell as of 2021-03-15.

=== Scripts ===

0-sudo-init.sh is the only part which needs root or sudo to install
prerequisites needed to pass OE sanity check and to install proper
time for test.sh. This needs to be executed manually before anything
else.

1-init.sh will setup the workspace, download all needed metadata
layers and configure the build (just add layers to bblayers.conf
and add couple extra components to core-image-sato)

2-build-test.sh is very short build, which can be interactively
executed just to confirm that everything works fine (e.g. OE sanity
check not complaining about anything else)

3-fetch.sh will fetch sources for all FOSS components which will
be built during the test, this is in separate script, because we don't
want to measure your network speed (or speed of upstream sites from
where it's being fetched).

Remaining scripts are all building core-image-sato image with different
value of BB_NUMBER_THREADS

4-build-all-cores.sh uses the default value oe.utils.cpu_count (the same
default as PARALLEL_MAKE which is problematic on builders which have too
many CPU threads or too little RAM), e.g. on AMD Ryzen 5 1600AF which has
6 cores, 12 threads, you can in worst case scenario end with 12 do_compile
tasks each spawning 12 gcc processes and 144 gcc's won't run well on 12
thread CPU and won't fit in e.g. 16GB RAM one of the tested builders have.
It won't even fit if you add 16GB swap and at that time we're measuring
performance of the disk with swap instead of using more sane build
configuration. The load during this build often goes above 150 and triggering
OOMK is common unless you have *a lot* of RAM (or swap).

5-build-8-bb-threads.sh uses 8 BB_NUMBER_THREADS this should be enough
to keep "lower" specs builders busy while keeping the builder relatively
usable.

6-build-16-bb-threads.sh uses 16 BB_NUMBER_THREADS which will be a bit
faster than 8 on powerful builders.

7-build-2-bb-threads.sh uses only 2 BB_NUMBER_THREADS which is good e.g.
for that AMD Ryzen 5 1600AF system which won't use much swap (can probably
finish without any swap at all). And someone can still interactively work
on such system while the build is running on background. But on more
powerful builders this is expected to be much slower.

test.sh runs all these scripts except 0-sudo-init.sh in sequence and
records the time and 20 longest running tasks for each of the steps.

It's necessary to remove:
poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp
between each step, because we want to build from scratch.

It's OK to run each step separately if you cannot block the builder
for 4-10 hours to run them all. Just copy all 3 lines for each step
from test.sh (e.g. modify test.sh to run only first 4 steps), then
run 5th, 6th separately next night and 7th the next one.

It's also OK to kill ongoing build and restarting just the remaining
steps later (It's hard to guess how much time it will need on your
system, but you can run whole test.sh over night and then just kill
it in the morning when you need the builder for something else, just
notice which step was the last one completely finished - you can see
it in the .log files).

With the rm_work currently enabled, it will still temporary need
around 150GB disk space (when all the big component builds are still
in progress and cannot be removed by rm_work yet).

After successfully finishing the steps it will be using around 42G
for "poky" directory, most of which are the temporary build artifacts:
2,7M    poky/build/cache
11G     poky/build/sstate-cache
17G     poky/build/tmp

you can remove these (like test.sh does between each step) with
rm -rf poky/build/bitbake-cookerdaemon.log poky/build/cache poky/build/sstate-cache poky/build/tmp

That leaves 15G in poky directory, which you can transfer to some
other builder you want to test which doesn't have unrestricted
access to the Internet.

=== Running ===

1) Read 0-sudo-init.sh and run with sudo if you agree.
2) run 1-init.sh manually and check output for some obvious errors
3) run 2-build-test.sh manually and again check output for some obvious
   errors, if unsure compare with my output in
   "ryzen-5-1600AF/2-build-test.log" if it ends with line
   NOTE: Tasks Summary: Attempted 42 tasks of which 0 didn't need to be rerun and all succeeded.
   then it's most likely OK, if still unsure about something contact me

The above shouldn't take more than 5 mins.

4) Delete "poky" directory and run test.sh

=== Sumitting the results ===

I would be very interested in all the results, the easiest way is to
create pull request on github.

Create directory describing your system e.g.:
dual-Xeon-E5-2670-8-channels/
dual-Xeon-E5-2698-v4-4-channels/
dual-Xeon-E5-2699-v3-8-channels/
ryzen-5-1600AF/

Move all *.log *top20 files from the top directory to the created one.

Create <your-directory>/results.txt with template like this:
SYS:	Tower
CPU:	6cores 12threads AMD Ryzen 5 1600AF
MB:	MSI B450-A PRO MAX
RAM:	16GB (2x8G DDR3200 HyperX Predator CL16 KHX3200C16D4/8GX
DISK:	2TB Gigabyte Aorus NVMe Gen4
FS:	ext4 with no journal, nobarrier (rw,noatime,nobarrier,stripe=128,data=ordered) - commit=6000 isn't used because it conflicts with no journal (https://lore.kernel.org/patchwork/patch/646499/)
OS:	Ubuntu 19.10

I usually use dmidecode + lshw + dmesg to find out the specs of the builder,
but I don't want to include it all automatically, it's up to you how much
information you're willing to share.

append "tail -n 5 *.log" from your directory which should show all times
and build summaries.

=== Results ===
For results see "results" branch in this repository.
