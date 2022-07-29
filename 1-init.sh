#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b langdale b9223d27bdebd1356b3ece4c8735f561c947d47d
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b langdale d466c12ed432f6d811dac6a80528a637ef5c658d
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b langdale 1f3ccca5678d7cbb221645227ec403aa767c16dd
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b langdale 2eb39477a784673baefa59640909b827ebb689b2
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b langdale da301d7c6627a5a1ee541a646aba22dc993109d9
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b langdale f02882e2aa9279ca7becca8d0cedbffe88b5a253
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
