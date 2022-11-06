#!/bin/bash

GITHUB_WORKSPACE="$(pwd)"

if [ ! -d AutoBuild-Actions ]; then
    git clone -b master https://github.com/xwings/AutoBuild-Actions.git AutoBuild-Actions
fi

cd ${GITHUB_WORKSPACE}/AutoBuild-Actions && git pull

cd ${GITHUB_WORKSPACE}
if [ ! -d openwrt ]; then
     git clone -b master https://github.com/coolsnowwolf/lede.git openwrt
fi

cd ${GITHUB_WORKSPACE}/openwrt && git pull
./scripts/feeds update -a
./scripts/feeds install -a

cd ${GITHUB_WORKSPACE}/AutoBuild-Actions/
chmod +x Scripts/AutoBuild_*.sh

cd ${GITHUB_WORKSPACE}/openwrt
source ${GITHUB_WORKSPACE}/AutoBuild-Actions/Scripts/AutoBuild_DiyScript.sh
source ${GITHUB_WORKSPACE}/AutoBuild-Actions/Scripts/AutoBuild_Function.sh
Firmware_Diy_Before
rm -f .config && cp ${GITHUB_WORKSPACE}/AutoBuild-Actions/Configs/x86_64 .config
make defconfig
Firmware_Diy_Main
Firmware_Diy
Firmware_Diy_Other
./scripts/feeds install -a
make defconfig
make download -j8
make -j8
[ "$?" == 0 ] && echo "Compile_Result=true"  || echo "Compile_Result=false"
