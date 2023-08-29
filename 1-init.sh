#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b kirkstone e19a76951b61ef7403dd64af844a3cfe16fda118
# add /proc/pressure collection in buildstats
git cherry-pick ac162116b3 45f1e9d953 1125adc33b 4678581ea0 6958024ed2
# pressure logic fixes and output
git cherry-pick ba94f9a3b19 24fe236a102 653ff4d85cb 8087c261b06

git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b kirkstone bff5bd937f0776166e81a63f3dd39ede348ef758
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b kirkstone 1f3ccca5678d7cbb221645227ec403aa767c16dd
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b kirkstone 529620141e773080a6a7be4615fb7993204af883
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b kirkstone 2d08d6bf376a1e06c53164fd6283b03ec2309da4
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b kirkstone f02882e2aa9279ca7becca8d0cedbffe88b5a253
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
