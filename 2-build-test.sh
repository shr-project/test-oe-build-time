#!/bin/sh

# Build very small component, just to interactivelly check that your
# build environment is working, before running anything long

cd poky
. ./oe-init-build-env
rm -rf bitbake-cookerdaemon.log cache sstate-cache tmp
bitbake -k m4-native 2>&1
