#!/bin/bash

LEDE_STABLE="03a0395"
OPENCLASH_FILE="0.45.70-beta"
CONFIG_FILE="x86_64"

XWINGSWRT_BUILDSPACE="$(pwd)/buildspace"
COMPILE_DATE="$(date +%Y%m%d%H%M)"

if [ ! -d ${XWINGSWRT_BUILDSPACE} ]; then
    mkdir -p ${XWINGSWRT_BUILDSPACE}/tmp
fi

cd ${XWINGSWRT_BUILDSPACE}
if [ ! -d openwrt ]; then
    git clone -b master https://github.com/coolsnowwolf/lede.git openwrt
    cd openwrt
    git checkout ${LEDE_STABLE}
    git switch -c latest
fi

cd ${XWINGSWRT_BUILDSPACE}/tmp
wget https://github.com/vernesong/OpenClash/archive/refs/tags/v${OPENCLASH_FILE}.tar.gz
tar xvzf v${OPENCLASH_FILE}.tar.gz
cp -aRp OpenClash-${OPENCLASH_FILE}/luci-app-openclash ${XWINGSWRT_BUILDSPACE}/openwrt/lean/

cd ${XWINGSWRT_BUILDSPACE}/openwrt && git pull
echo "src-git helloworld https://github.com/fw876/helloworld" >> feeds.conf.default

cd ${XWINGSWRT_BUILDSPACE}/openwrt
./scripts/feeds update -a
./scripts/feeds install -a
cp ${XWINGSWRT_BUILDSPACE}/../${CONFIG_FILE} ${XWINGSWRT_BUILDSPACE}/openwrt/.config
make defconfig
make menuconfig
make download -j8
make -j8

if [ -f ${XWINGSWRT_BUILDSPACE}/openwrt/bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz ]; then
    cp ${XWINGSWRT_BUILDSPACE}/openwrt/bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz /mnt/shared0/www/firmware/xwingsrt-x86-64-squashfs-$COMPILE_DATE-BIOS-Full.img.gz &&
    rm -rf ${XWINGSWRT_BUILDSPACE}
fi