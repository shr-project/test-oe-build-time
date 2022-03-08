#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b kirkstone 8a4c53ee762c1ee02ba282d265e12e733c81ce82
# to fix libsdl2-native build on gentoo with libunwind installed
git cherry-pick 0d6b4a93e58f72e17fe0839d3f337efafded1277
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b kirkstone 4837db1d965c51e4a2c5971e6a126c896e5b401a
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b kirkstone ccbdc01df693d675d75d01ab798cc5c377466ac2
# to fix firefox build after:
# https://git.openembedded.org/openembedded-core/commit/meta/classes/rust-common.bbclass?id=997d54363a3cb3a0e949b3626855f2fa41afeb2b
wget https://github.com/OSSystems/meta-browser/commit/df743dd5e9a660b64e750800747e68445914ee8f.patch
git am df743dd5e9a660b64e750800747e68445914ee8f.patch
# and with wayland-1.20
wget https://github.com/OSSystems/meta-browser/commit/dfeb4defc8b939714ccce797c30245ae4b3ede93.patch
git am dfeb4defc8b939714ccce797c30245ae4b3ede93.patch
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b kirkstone a3f218e9db0caeb544d834a0f3f374aac7d0e4f3
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b kirkstone 8efb230dd73cfd19e575ff42fea979d977b05c97
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b kirkstone f02882e2aa9279ca7becca8d0cedbffe88b5a253
cd ..

. ./oe-init-build-env
if ! grep -q meta-qt5 conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-qt5/g' conf/bblayers.conf
fi
if ! grep -q meta-clang conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-clang/g' conf/bblayers.conf
fi
if ! grep -q meta-oe conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-openembedded\/meta-oe/g' conf/bblayers.conf
fi
if ! grep -q meta-browser conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-browser\/meta-firefox/g' conf/bblayers.conf
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-browser\/meta-chromium/g' conf/bblayers.conf
fi
if ! grep -q meta-python2 conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-python2/g' conf/bblayers.conf
fi

cat >> conf/local.conf << EOF
IMAGE_INSTALL:append:pn-core-image-sato = " qtwebengine qtwebkit chromium-x11 firefox epiphany"
MACHINE = "qemux86-64"
INHERIT += "rm_work"
EOF
