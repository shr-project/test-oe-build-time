#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengine)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b scarthgap 83793ccd865e3e72563e6d5733b6bd02943feb8a
# to fix build on host with gcc-14
# 4a1234df65 db: ignore implicit-int and implicit-function-declaration issues fatal with gcc-14
# 818fe3d7df yocto-uninative: Update to 4.5 for gcc 14
git cherry-pick 31b4ec9fd6 b77236fdeb
# to fix build on host with python-13
# 6741c78d3f ninja: fix build with python 3.13
# 679b1842bb pseudo: Fix envp bug and add posix_spawn wrapper
# d672cd4c93 pseudo: Update to include open symlink handling bugfix
# f2e9c85eca pseudo: Fix to work with glibc 2.40
# 2d5281492d pseudo: Update to pull in python 3.12+ fix
git cherry-pick 6741c78d3f 2d5281492d f2e9c85eca d672cd4c93 679b1842bb
# to fix build on host with glibc >= 2.41
# d59b8312e9 qemu: Do not define sched_attr with glibc >= 2.41
# other just for cherry-pick to apply cleanly:
# 2775596cb2 qemu: upgrade 8.2.3 -> 8.2.7
# dc5dd6ec19 qemu: back port patches to fix riscv64 build failure
# 0069bab748 qemu: fix CVE-2024-7409
# 8c533e9242 qemu: fix CVE-2024-4467
# aa02ad000d qemu: upgrade 8.2.2 -> 8.2.3
# 47789523dd qemu: Upgrade 8.2.1 -> 8.2.2
git cherry-pick 47789523dd aa02ad000d 8c533e9242 0069bab748 dc5dd6ec19 2775596cb2 d59b8312e9

git clone https://github.com/meta-qt5/meta-qt5.git
cd meta-qt5
git checkout -b scarthgap eb828418264a49b8d00035cb3d7b12fcea3be801
cd ..

git clone https://github.com/OSSystems/meta-browser.git
cd meta-browser
git checkout -b scarthgap 1ed2254d72a4c25879014c98be287a7e3e22904c
cd ..

git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded
git checkout -b scarthgap 4a7bb77f7ebe0ac8be5bab5103d8bd993e17e18d
cd ..

git clone https://github.com/kraj/meta-clang.git
cd meta-clang
git checkout -b scarthgap e7dceb1c92caf7f21ef1d7b49c85328c30cffd90
cd ..

git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b scarthgap f02882e2aa9279ca7becca8d0cedbffe88b5a253
echo 'LAYERSERIES_COMPAT_meta-python2 = "scarthgap"' >> conf/layer.conf
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
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-browser\/meta-chromium/g' conf/bblayers.conf
fi
if ! grep -q meta-python2 conf/bblayers.conf ; then
  sed -i 's/^\(.*\)meta-yocto-bsp/\1meta-yocto-bsp \\\n\1meta-python2/g' conf/bblayers.conf
fi

cat >> conf/local.conf << EOF
IMAGE_INSTALL:append:pn-core-image-sato = " qtwebengine qtwebkit chromium-x11 epiphany"
MACHINE = "qemux86-64"
INHERIT += "rm_work"
EOF
