#!/bin/bash

COMPILE_OPTION=$1
GITHUB_WORKSPACE="$(pwd)/AutoBuild-Actions"
CONFIG_FILE="x86_64"
GITHUB_ENV="${GITHUB_WORKSPACE}/AutoBuild-Action_ENV"
CONFIG_FILE="${GITHUB_WORKSPACE}/Configs/${CONFIG_FILE}"
DEFAULT_SOURCE="coolsnowwolf/lede:master"
REPO_URL="https://github.com/$(cut -d \: -f 1 <<< ${DEFAULT_SOURCE})"
REPO_BRANCH=$(cut -d \: -f 2 <<< ${DEFAULT_SOURCE})

if [ ! -d AutoBuild-Actions ]; then
    git clone -b master https://github.com/xwings/AutoBuild-Actions.git AutoBuild-Actions
fi

cd ${GITHUB_WORKSPACE} && git pull

echo "CONFIG_FILE=$CONFIG_FILE" >> $GITHUB_ENV
echo "Tempoary_IP=" >> $GITHUB_ENV
echo "Tempoary_FLAG=" >> $GITHUB_ENV
echo "REPO_URL=$REPO_URL" >> $GITHUB_ENV
echo "REPO_BRANCH=$REPO_BRANCH" >> $GITHUB_ENV
echo "Compile_Date=$(date +%Y%m%d%H%M)" >> $GITHUB_ENV
echo "Display_Date=$(date +%Y/%m/%d)" >> $GITHUB_ENV

cd ${GITHUB_WORKSPACE}
if [ ! -d openwrt ]; then
     git clone -b master https://github.com/coolsnowwolf/lede.git openwrt
fi

cd ${GITHUB_WORKSPACE}/openwrt && git pull
./scripts/feeds update -a
./scripts/feeds install -a

cd ${GITHUB_WORKSPACE}/openwrt
chmod +x ${GITHUB_WORKSPACE}/Scripts/AutoBuild_*.sh
cp ${CONFIG_FILE} ${GITHUB_WORKSPACE}/openwrt/.config
source ${GITHUB_WORKSPACE}/Scripts/AutoBuild_DiyScript.sh
source ${GITHUB_WORKSPACE}/Scripts/AutoBuild_Function.sh
make defconfig
Firmware_Diy_Before
rm -f .config && cp ${CONFIG_FILE} ${GITHUB_WORKSPACE}/openwrt/.config
Firmware_Diy_Main
Firmware_Diy
Firmware_Diy_Other
./scripts/feeds install -a
make defconfig
make download -j8
make -j8
