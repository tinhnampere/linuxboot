#!/bin/bash
set -x

export WORKSPACE=${PWD}
TOOLCHAINS=${WORKSPACE}/toolchain
PLATFORM_MAKE_DIR=${WORKSPACE}/mainboards/ampere/jade

# set env
export PATH=${TOOLCHAINS}/go/bin:${TOOLCHAINS}/bin:$PATH
export PATH=${WORKSPACE}/u-root:$PATH
export GOPATH=${TOOLCHAINS}
export GOENV=${TOOLCHAINS}/.config/go/env
export GOCACHE=${TOOLCHAINS}/.cache/go-build
export GO111MODULE=off

#clear old-output
rm -rf ${PLATFORM_MAKE_DIR}/flashkernel
rm -rf ${PLATFORM_MAKE_DIR}/flashinitramfs*

"${CROSS_COMPILE}"gcc --version || exit 1
make -C ${PLATFORM_MAKE_DIR} flashkernel ARCH=arm64 CROSS_COMPILE=${CROSS_COMPILE}
if [ $? -ne 0 ]; then
    echo "build kernel fail"
else
    echo "done"
fi
