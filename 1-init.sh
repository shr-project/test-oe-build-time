#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b nanbield 05affd7d0d143d6fa5c6aff0d40c5d9e046f4b0c
git am ../0001-runqueue-show-more-pressure-data.patch

git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b nanbield c83b6529359fe21d6825f4fd4c9fdea2f8000a85
cd ..

git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b nanbield 0f2de2d3ede1388b841642ad5454831db6bda315
cd ..

git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b nanbield 491b7592f4408a1d7f32ddfb12b2c1613bcadfe1
cd ..

git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b nanbield 6df9ffeac401b4074ce7baa0031bfd8bb4010374
cd ..

git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b nanbield f02882e2aa9279ca7becca8d0cedbffe88b5a253
echo 'LAYERSERIES_COMPAT_meta-python2 = "mickledore"' >> conf/layer.conf
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
