#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b dunfell d695bd0d3dc66f2111a25c6922f617be2d991071
# add /proc/pressure collection in buildstats
git cherry-pick ac162116b3 45f1e9d953 4678581ea0 6958024ed2 48a6d84de1

git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b dunfell 5ef3a0ffd3324937252790266e2b2e64d33ef34f
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b dunfell 5e58ff65facc27a3054a4d3f97d3329342d49afa
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b dunfell 52cee67833d1975a5bd52e4556c4cd312425a017
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b dunfell 3bb001d3f364bbf6588fed04b9ee2c7e74a0beba
cd ..
git clone https://github.com/meta-rust/meta-rust.git
cd meta-rust
git checkout -b dunfell 53c9aabda3bb3813cd86002cbabb112d0989a4b2
# rust-llvm-native
# there is no matching fix for 1.37.0 in meta-rust and we would need to upgrade into 1.43.0
git am ../../0001-rust-llvm-1.37.0-fix-build-with-gcc-10-gcc-12-and-un.patch
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b dunfell b901080cf57d9a7f5476ab4d96e56c30db8170a8
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
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-browser/g' conf/bblayers.conf
fi
if ! grep -q meta-python2 conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-python2/g' conf/bblayers.conf
fi

# Needed to build firefox
echo 'HOSTTOOLS += "python python2.7"' >> conf/bblayers.conf
cat >> conf/local.conf << EOF
require conf/distro/include/rust_versions.inc
RUST_VERSION = "1.37.0"
EOF

cat >> conf/local.conf << EOF
IMAGE_INSTALL_append_pn-core-image-sato = " qtwebengine qtwebkit chromium-x11 firefox epiphany"
MACHINE = "qemux86-64"
INHERIT += "rm_work"
EOF
