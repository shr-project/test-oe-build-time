#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengine)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b scarthgap ae7056844aa05a239384335a66684394e10290a6

git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b scarthgap b8e1ae8ce6140f6084388842751280b55d55988b
cd ..

git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b scarthgap 81d037b8650a73339dab97ceba9917b1f31ca652
cd ..

git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b scarthgap b29e413d92135ba2d25ed53cea09e45a596f4bf1
cd ..

git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b scarthgap 73c00a5a0bebc871854e43cc1f0fe5bd5e5ad1d7
cd ..

git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b scarthgap f02882e2aa9279ca7becca8d0cedbffe88b5a253
echo 'LAYERSERIES_COMPAT_meta-python2 = "scarthgap"' >> conf/layer.conf
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
