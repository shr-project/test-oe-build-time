#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b hardknott 3cda6c0bd175282903079dea4affb3fcd290f137
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b hardknott a00af3eae082b772469d9dd21b2371dd4d237684
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b hardknott bdde7ca1fed0e29441d94ad6af8319b6df48063a
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b hardknott 36bb7d02a0f189768b380747a2349406ceffacbf
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b hardknott e8a0bada69637ff7a767d387b803a42123aead0b
cd ..
git clone https://github.com/meta-rust/meta-rust.git
cd meta-rust
git checkout -b hardknott 9a035fe27262bb23676da9f9f583e3ee39b0a377
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b hardknott 5f4db648e00cf1c41e0999d3b184a02cde225143
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
