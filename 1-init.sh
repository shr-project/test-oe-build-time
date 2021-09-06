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
# https://github.com/OSSystems/meta-browser/pull/554
wget https://github.com/OSSystems/meta-browser/commit/bf2ff922ad8c103bffc8bae7c77a504d4ee31924.patch
git am bf2ff922ad8c103bffc8bae7c77a504d4ee31924.patch
# https://github.com/OSSystems/meta-browser/pull/553
for p in 927ccad3766489a87b5f3da15acc8e64ffa0358e 6ef08fdfe1daaa7c4502868b30294fe0be4788ee 37eb6560de8aecef7091c16becd110fa5a2b8249 39f5dff52587b07b0a1be88b55f713454266525a f1e11805e2fe163ae73977ef8afaa8921a2ba038 b7fc5af15ee4dd80936c2bda1f0ecd683acd5257; do
  wget https://github.com/OSSystems/meta-browser/pull/553/commits/$p.patch
  git am $p.patch
done
# https://github.com/OSSystems/meta-browser/pull/555
wget https://github.com/OSSystems/meta-browser/commit/b01500171df422e63d0a10b3287bf65a230125b8.patch
git am b01500171df422e63d0a10b3287bf65a230125b8.patch
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
