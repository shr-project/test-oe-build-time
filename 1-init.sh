#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b dunfell ed3bdd7fbc633124c01008a6dc6952c9d0857019
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b dunfell fdd19517e17240b0b61765bd02fc483a1bde986f
cd ..
git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b dunfell 5e58ff65facc27a3054a4d3f97d3329342d49afa
cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b dunfell e413c1ef621688e69bb7830bb3151ed23b30b73e
cd ..
git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b dunfell 503aa977b27be0506fb6ac21fbf9e8b049b82247
cd ..
git clone https://github.com/meta-rust/meta-rust.git
cd meta-rust
git checkout -b dunfell 7f235b6f8973cc5269448375f2a8f9867bb2a369
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b dunfell e2ef0dd8fa13d6b96e44773b09d07e4817d0a44d
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
if ! grep meta-python2 conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-python2/g' conf/bblayers.conf
fi

# Needed to build firefox
echo 'HOSTTOOLS += "python python2.7"' >> conf/bblayers.conf
cat >> conf/local.conf << EOF
RUST_VERSION = "1.37.0"
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
