#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b honister b978f7c3a028ff4cc61de79d296723b5f873651d
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b honister 2a38fca150f065f869ed530fffe1a07beec80692
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b honister a7d78e7d86869c3e9c9dbcc5be8774f54a03e13a
sed -i 's/LAYERDEPENDS_firefox-browser-layer = "clang-layer core openembedded-layer rust-layer"/LAYERDEPENDS_firefox-browser-layer = "clang-layer core openembedded-layer"/g' meta-firefox/conf/layer.conf
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b honister 967fe6730c6b0ab9fa8f350adef7bffea0aeb67b
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b honister 5187604e18b970e486b88e6f2eba6a454ef4f7ef
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b honister f522fa70f93a9339f3b9991082af69a09fde675a
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
