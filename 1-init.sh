#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone https://git.yoctoproject.org/git/poky
cd poky
git checkout -b zeus 73fe0e273b4e00dcb08122c4f54fc65316e2a793
git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b zeus a582fd4c810529e9af0c81700407b1955d1391d2
cd ..

. ./oe-init-build-env
sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-qt5/g' conf/bblayers.conf

cat >> conf/local.conf << EOF
IMAGE_INSTALL_append_pn-core-image-sato = " qtwebengine"
MACHINE = "qemux86-64"
EOF
