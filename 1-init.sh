#!/bin/sh

# Clones the metadata (reference DISTRO poky + meta-qt5 for bigger components like qtwebengin)
# Adds extra package to be built and installed in core-image-sato image
# And sets qemux86-64 target MACHINE

git clone git://git.yoctoproject.org/poky
cd poky
git checkout -b dunfell ed3bdd7fbc633124c01008a6dc6952c9d0857019
# backport few fixes for ubuntu-21.04 compatibility which are in newer dunfell
# but don't want to introduce all changes as it might affect the build time
# libtirpc:
# 4a283230f5 libtirpc: remove extra "-fcommon" from CFLAGS
# 00ea8cc16f libtirpc: upgrade 1.2.5 -> 1.2.6
git cherry-pick 00ea8cc16f 4a283230f5
# gdbm:
# c7ec0a4121 gdbm: add patch to fix link failure against gcc 10
git cherry-pick c7ec0a4121
# libxcb-native:
# 75e33acd40 xcb-proto: backport fix for python gcd function
git cherry-pick 75e33acd40
# dtc-native:
# 74bf6213de dtc: update to 1.6.0
git cherry-pick 74bf6213de
# groff-native:
# e3a6561373 site: Make sys_siglist default to no
git cherry-pick e3a6561373
# libcomps-native:
# 07d53f0a28 libcomps: update to 0.1.15
git cherry-pick 07d53f0a28
# binutils-native:
# c1fafbd8e2 binutils: add patch to fix issues with gcc 10
git cherry-pick c1fafbd8e2
# pseudo-native:
# c2adb60531 pseudo: Fix attr errors due to incorrect library resolution issues
# a9206a27e4 pseudo: Switch to oe-core branch in git repo
# 338aa0930d pseudo: merge in fixes for setfacl issue
# fd1e2f595b pseudo: Update to add OFC fcntl lock updates
# 1a71eed4c6 pseudo: fix renaming to self
# b0c9032431 pseudo: Ignore mismatched inodes from the db
# 82fd0a203f pseudo: Add support for ignoring paths from the pseudo DB
# 3b7f2c6e8a pseudo: Abort on mismatch patch
# 50beafa24f psuedo: Add tracking of linked files for fds
# c3146b9acc pseudo: Fix xattr segfault
# 3ed2af928b pseudo: Add may unlink patch
# 74e9146275 pseudo: Add pathfix patch
# 6821ab3485 pseudo: Fix statx function usage
# 625e0cdf84 pseudo: Update to account for patches merged on branch
# 5b05fbc910 pseudo: Upgrade to include mkostemp64 wrapper
# f9ef25050e pseudo: Simplify pseudo_client_ignore_path_chroot()
# e837c1790b pseudo: Update to print PSEUDO_LOGFILE in abort message on path mismatches
# 94a2680ae4 pseudo: Drop patches merged into upstream branch
# 8b3da844ab pseudo: Add lchmod wrapper
# d1a8712f0b pseudo: Update for arm host and memleak fixes/cleanup
# 45a49e7fe0 pseudo: Update to include passwd and file renaming fixes
# 886535cb5c pseudo: Update to work with glibc 2.33
# eef84ad311 pseudo: Update for rename and faccessat fixes
# 33ef864901 pseudo: Update to include fixes for glibc 2.33
git cherry-pick c2adb60531 a9206a27e4 338aa0930d fd1e2f595b 1a71eed4c6 b0c9032431 82fd0a203f 3b7f2c6e8a 50beafa24f c3146b9acc 3ed2af928b 74e9146275 6821ab3485 625e0cdf84 5b05fbc910 f9ef25050e e837c1790b 94a2680ae4 8b3da844ab d1a8712f0b 45a49e7fe0 886535cb5c eef84ad311 33ef864901
# 5d3de28c9d sstatesig: Log timestamps for hashequiv in reprodubile builds for do_package
# 4e7c21160b base/bitbake.conf: Enable pseudo path filtering
# f29740c582 bitbake.conf: Extend PSEUDO_IGNORE_PATHS to ${COREBASE}/meta
# 58f59ad6b6 base.bbclass: use os.path.normpath instead of just comparing WORKDIR and S as strings
git cherry-pick 5d3de28c9d 4e7c21160b f29740c582 58f59ad6b6
# gobject-introspection:
# ec6f9694ea qemu: Backport patch to avoid assertion fails on icache line size
git cherry-pick ec6f9694ea

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
# rust-llvm-native
# there is no matching fix in meta-rust
git am ../../0001-rust-llvm-1.37.0-fix-build-with-gcc-10.patch
cd ..
git clone git://git.openembedded.org/meta-python2
cd meta-python2
git checkout -b dunfell e2ef0dd8fa13d6b96e44773b09d07e4817d0a44d
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
