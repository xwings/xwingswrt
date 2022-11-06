#!/bin/bash

GITHUB_WORKSPACE="$(pwd)"

if [ ! -d AutoBuild-Actions ]; then
    git clone https://github.com/xwings/AutoBuild-Actions.git
fi

cd ${GITHUB_WORKSPACE}/AutoBuild-Actions && git pull

if [ ! -d openwrt ]; then
     git clone -b master https://github.com/coolsnowwolf/lede.git openwrt
fi

cd ${GITHUB_WORKSPACE}/AutoBuild-Actions/openwrt && git pull
./scripts/feeds update -a
./scripts/feeds install -a
rm -f .config && cp ../Configs/x86_64 .config
make defconfig

cd ${GITHUB_WORKSPACE}/AutoBuild-Actions/
chmod +x Scripts/AutoBuild_*.sh
source Scripts/AutoBuild_DiyScript.sh
source Scripts/AutoBuild_Function.sh

Firmware_Diy_Main
Firmware_Diy
Firmware_Diy_Other

cd ${GITHUB_WORKSPACE}/AutoBuild-Actions/openwrt
./scripts/feeds install -a
make defconfig
make download -j8

make -j8
[ "$?" == 0 ] && echo "Compile_Result=true"  || echo "Compile_Result=false"
