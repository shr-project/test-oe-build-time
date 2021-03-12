#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b hardknott ffc36f351f47e59beff8240e56cdc8648188ef19
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b hardknott 324843cb1a2feb5f5c7b0064ca33edaa605cb749
cd ..
# temporarily use my fork with fix for newer meta-rust and split for meta-firefox and meta-chromium
# git clone https://github.com/OSSystems/meta-browser.git
git clone https://github.com/shr-project/meta-browser.git
cd meta-browser
git checkout -b hardknott 4e17167735f3ad7119548872108c4bafa3d38f07
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b hardknott 589aa162cead42acdd7e8dbd7c0243b95e341f19
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b hardknott 3fbc916a7987f15f874f40f9e5b531eb72bffc7a
cd ..
git clone https://github.com/meta-rust/meta-rust.git
cd meta-rust
git checkout -b hardknott 9a035fe27262bb23676da9f9f583e3ee39b0a377
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b hardknott 044015255944fd8db139caec8981f2957f8e2604
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
if ! grep -q meta-rust conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-rust/g' conf/bblayers.conf
fi
if ! grep -q meta-browser conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-browser\/meta-firefox/g' conf/bblayers.conf
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-browser\/meta-chromium/g' conf/bblayers.conf
fi
if ! grep -q meta-python2 conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-python2/g' conf/bblayers.conf
fi

cat >> conf/local.conf << EOF
IMAGE_INSTALL_append_pn-core-image-sato = " qtwebengine qtwebkit chromium-x11 firefox epiphany"
MACHINE = "qemux86-64"
INHERIT += "rm_work"
EOF
