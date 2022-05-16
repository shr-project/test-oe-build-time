#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b langdale bd66a18eaa463c2eab291fea68039bf0d61c7b8b
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b langdale 6b29b21775558eea1a3ef3007133f08849b61b00
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b langdale 726f2e831c62a4fa894fcfd93c283065845c8b18
# To fix build with rust-1.60 add pending patch from PR
wget https://github.com/OSSystems/meta-browser/pull/638/commits/c4cc1810020ec2d395a718742bf05dbbc88fbc6d.patch
git am c4cc1810020ec2d395a718742bf05dbbc88fbc6d.patch
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b langdale 1fa8cfed01b3088dc33e0958e83f1162ffc1b91b
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b langdale 85d956d95401479ca666139e31f662f60c156d5f
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
