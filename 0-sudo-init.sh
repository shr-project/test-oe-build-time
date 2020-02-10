#!/bin/sh

# Needed for OE sanity
apt-get install -y build-essential chrpath git locales lsb-release iputils-ping python python2.7 python3 texinfo cpio diffstat gawk wget python3-distutils bzr iproute2

# Needed for test.sh
apt-get install -y time
