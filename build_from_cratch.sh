#!/bin/bash

set -x
export WORKSPACE=${PWD}

# update submodule
git submodule update --init

# install go, we do not use system's GO
GO_VERSION=1.18.4
TOOLCHAINS=${WORKSPACE}/toolchain
PLATFORM_MAKE_DIR=${WORKSPACE}/mainboards/ampere/jade

# set env
export PATH=${TOOLCHAINS}/go/bin:${TOOLCHAINS}/bin:$PATH
export PATH=${WORKSPACE}/u-root:$PATH
export GOPATH=${TOOLCHAINS}
export GOENV=${TOOLCHAINS}/.config/go/env
export GOCACHE=${TOOLCHAINS}/.cache/go-build
export GO111MODULE=off


# clear toolchains
sudo rm -rf ${TOOLCHAINS}
mkdir -p ${TOOLCHAINS}
cd ${TOOLCHAINS} && wget https://go.dev/dl/go"${GO_VERSION}".linux-amd64.tar.gz
tar -xzf go"${GO_VERSION}".linux-amd64.tar.gz
cd ${WORKSPACE} || exit 1



# build u-root
## currenly, u-root does not support "go module" .... hmmm
## use go get -> need set GO111MODULE=on to use "corrected version" ... hmm
GO111MODULE=off go get -d github.com/u-root/u-root
GO111MODULE=off go get -d github.com/u-root/cpu/...
## get the binary
GO111MODULE=on go install github.com/u-root/u-root@latest
cd ${WORKSPACE} || exit 1


# Ok -> build flash kernel now
## clean old output
rm -rf ${PLATFORM_MAKE_DIR}/flashkernel
rm -rf ${PLATFORM_MAKE_DIR}/flashinitramfs*
make -C ${PLATFORM_MAKE_DIR} getkernel
## check cross compiler
"${CROSS_COMPILE}"gcc --version || exit 1
make -C ${PLATFORM_MAKE_DIR} flashkernel ARCH=arm64 CROSS_COMPILE=${CROSS_COMPILE}
if [ $? -ne 0 ]; then
    echo "build kernel fail"
else
    echo "done"
fi