#!/bin/sh

# Fetches all upstream sources need to build our modified core-image-sato
# So that follow-up "build" tests aren't influenced by speed of your network
# (or speed upstream sites from where it downloads)

cd poky
. ./oe-init-build-env
rm -rf bitbake-cookerdaemon.log cache downloads sstate-cache tmp
bitbake --runall=fetch core-image-sato
