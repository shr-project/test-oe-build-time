#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengine)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b scarthgap bab0f9f62af9af580744948dd3240f648a99879a

git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b scarthgap c5cd0f5240bbddaa292aa3fee5e12576550c6710
echo 'LAYERSERIES_COMPAT_qt5-layer = "scarthgap"' >> conf/layer.conf
cd ..

git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b scarthgap a5109f054f9269e88225fe15b02174026574712b
cd ..

# Newer chromium uses -Zexternal-clangrt since:
# https://chromium.googlesource.com/chromium/src/+/7d029cad43d3bf03b0464d9e3c55cc0f8b5474e2
# and rust-1.75.0 in oe-core/scarthgap doesn't support it yet:
# error: unknown unstable option: `external-clangrt`
# it was adde din 1.78.0 with:
# https://github.com/rust-lang/rust/pull/121207
# use 1.85.1 from scarthgap/rust branch
git clone https://git.yoctoproject.org/meta-lts-mixins
cd meta-lts-mixins
git checkout -b scarthgap 65b35821c8e39b13b20f0413c315d0c8f1a64a11
cd ..

git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b scarthgap e92d0173a80ea7592c866618ef5293203c50544c
cd ..

git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b scarthgap eaa08939eaec9f620b14742ff3ac568553683034
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
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-lts-mixins/g' conf/bblayers.conf
fi

cat >> conf/local.conf << EOF
IMAGE_INSTALL:append:pn-core-image-sato = " qtwebengine qtwebkit chromium-x11 firefox epiphany"
MACHINE = "qemux86-64"
INHERIT += "rm_work"
EOF
