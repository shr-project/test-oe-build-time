#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b dunfell d20ef1f5a5de7820b3e9b7f539b51f94954e9cd5

git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b dunfell b4d24d70aca75791902df5cd59a4f4a54aa4a125
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b dunfell 5e58ff65facc27a3054a4d3f97d3329342d49afa
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b dunfell 346681e7bf9c78008a845fc89031be4fd4ceb3a1
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b dunfell e63d6f9abba5348e2183089d6ef5ea384d7ae8d8
cd ..
git clone https://github.com/meta-rust/meta-rust.git
cd meta-rust
git checkout -b dunfell 53c9aabda3bb3813cd86002cbabb112d0989a4b2
# rust-llvm-native
# there is no matching fix for 1.37.0 in meta-rust and we would need to upgrade into 1.43.0
git am ../../0001-rust-llvm-1.37.0-fix-build-with-gcc-10.patch
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b dunfell ed4876c1a2f0808073fa7dfb32ef1ccb907ad5de
cd ..

. ./oe-init-build-env
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-qt5/g' conf/bblayers.conf
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-clang/g' conf/bblayers.conf
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-openembedded\/meta-oe/g' conf/bblayers.conf
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-rust/g' conf/bblayers.conf
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-browser/g' conf/bblayers.conf
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-python2/g' conf/bblayers.conf

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
