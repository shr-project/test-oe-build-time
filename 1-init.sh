#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b honister 0fbf414b39f1ce3a055c5baeba755a05c438ec0d
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b honister d38470c2632d6626c0a6c0f91a519589f9f1ae55
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b honister 3ae42a6e38b30da250276baed329cd999de84487
# to fix build on Ubuntu-22.04 with python3-3.10
git am ../../0001-chromium-fix-compatibility-with-python3-3.10.patch
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b honister 0fb490a08ce30b47a5ccd2fdc3448b08e0d9e4e9
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b honister 088904d40231d9e099c2f5039cd3c2bc47d332d1
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b honister 5243d509aebff378c1ae9d3dff6a29cfdc0dee1f
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
