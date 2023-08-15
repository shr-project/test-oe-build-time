#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b mickledore 0a98281d37b0bd8dc1548c390216cb3978e36e0e
git am ../0001-runqueue-show-more-pressure-data.patch

git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b mickledore d86e2e82c15d186141713515dfd1373013aaebd5
cd ..

git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b mickledore 1f3ccca5678d7cbb221645227ec403aa767c16dd
cd ..

git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b mickledore 75cf318cef3b4ee81fad2782cf063ecd69ba8842
cd ..

git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b mickledore af4dcba009ba98250315520f3003fde4ee164cce
cd ..

git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b mickledore f02882e2aa9279ca7becca8d0cedbffe88b5a253
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
