#!/bin/sh

#TEST=128G-4-channels-64G-swap
#./8-build-individual-components.sh
#mkdir -p threadripper-3970x-128gb/8-build-individual-components/$TEST/
#mv 8-build-individual-components.*.log threadripper-3970x-128gb/8-build-individual-components/$TEST/

TEST=128G-4-channels-64G-swap-tmpfs
mount poky/build/tmp
./8-build-individual-components.sh
mkdir -p threadripper-3970x-128gb/8-build-individual-components/$TEST/
mv 8-build-individual-components.*.log threadripper-3970x-128gb/8-build-individual-components/$TEST/

umount poky/build/tmp
sudo /usr/sbin/swapoff -a

#TEST=128G-4-channels-no-swap
#./8-build-individual-components.sh
#mkdir -p threadripper-3970x-128gb/8-build-individual-components/$TEST/
#mv 8-build-individual-components.*.log threadripper-3970x-128gb/8-build-individual-components/$TEST/

TEST=128G-4-channels-no-swap-tmpfs
mount poky/build/tmp
./8-build-individual-components.sh
mkdir -p threadripper-3970x-128gb/8-build-individual-components/$TEST/
mv 8-build-individual-components.*.log threadripper-3970x-128gb/8-build-individual-components/$TEST/
