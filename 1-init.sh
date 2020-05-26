#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b dunfell ed3bdd7fbc633124c01008a6dc6952c9d0857019
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b dunfell fdd19517e17240b0b61765bd02fc483a1bde986f
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b dunfell 5e58ff65facc27a3054a4d3f97d3329342d49afa
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b dunfell e413c1ef621688e69bb7830bb3151ed23b30b73e
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b dunfell 503aa977b27be0506fb6ac21fbf9e8b049b82247
cd ..
git clone https://github.com/meta-rust/meta-rust.git
cd meta-rust
git checkout -b dunfell d2ff87ca5545b8081b16ac8f53ed4295593208c6
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b dunfell e2ef0dd8fa13d6b96e44773b09d07e4817d0a44d
cd ..

. ./oe-init-build-env
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-qt5/g' conf/bblayers.conf
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-clang/g' conf/bblayers.conf
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-openembedded\/meta-oe/g' conf/bblayers.conf
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-rust/g' conf/bblayers.conf
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-browser/g' conf/bblayers.conf
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-python2/g' conf/bblayers.conf

cat >> conf/local.conf << EOF
IMAGE_INSTALL_append_pn-core-image-sato = " qtwebengine qtwebkit chromium-x11 firefox epiphany"
MACHINE = "qemux86-64"
INHERIT += "rm_work"
EOF
