#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b gatesgarth 4e4a302e37ac06543e9983773cdb4caf7728330d
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b gatesgarth 8d5672cc6ca327576a814d35dfb5d59ab24043cb
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b gatesgarth 5e07a7897945dd91d75169975178005d9d9aa200
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b gatesgarth 1a53121ff54732648a4ee1e96643106d4d36c524
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b gatesgarth 6b224af8d109c5b5be23444423fc98246c94c055
cd ..
git clone https://github.com/meta-rust/meta-rust.git
cd meta-rust
git checkout -b gatesgarth 53bfa324891966a2daf5d36dc13d4a43725aebed
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b gatesgarth 27d2aebdb4d78a608798a4f617d9bcfcbe4a635b
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
RUST_VERSION = "1.46.0"
PREFERRED_VERSION_rust-native ?= "\${RUST_VERSION}"
PREFERRED_VERSION_rust-cross-\${TARGET_ARCH} ?= "\${RUST_VERSION}"
PREFERRED_VERSION_rust-llvm-native ?= "\${RUST_VERSION}"
PREFERRED_VERSION_libstd-rs ?= "\${RUST_VERSION}"
PREFERRED_VERSION_cargo-native ?= "\${RUST_VERSION}"
EOF

cat >> conf/local.conf << EOF
IMAGE_INSTALL_append_pn-core-image-sato = " qtwebengine qtwebkit chromium-x11 firefox epiphany"
MACHINE = "qemux86-64"
INHERIT += "rm_work"
EOF
