#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengine)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b nanbield 7b8aa378d069ee31373f22caba3bd7fc7863f447

git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b nanbield b8e1ae8ce6140f6084388842751280b55d55988b
cd ..

git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b nanbield 81d037b8650a73339dab97ceba9917b1f31ca652
cd ..

git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b nanbield da9063bdfbe130f424ba487f167da68e0ce90e7d
cd ..

git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b nanbield b71a45630d19f210079f42f6394cdde65195fb84
cd ..

git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b nanbield f02882e2aa9279ca7becca8d0cedbffe88b5a253
echo 'LAYERSERIES_COMPAT_meta-python2 = "nanbield"' >> conf/layer.conf
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
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-browser\/meta-chromium/g' conf/bblayers.conf
fi
if ! grep -q meta-python2 conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-python2/g' conf/bblayers.conf
fi

cat >> conf/local.conf << EOF
IMAGE_INSTALL:append:pn-core-image-sato = " qtwebengine qtwebkit chromium-x11 epiphany"
MACHINE = "qemux86-64"
INHERIT += "rm_work"
EOF
