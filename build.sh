#!/bin/bash

COMPILE_ARCH=$1
CPU_COUNT=$(cat /proc/cpuinfo | grep processor | wc -l)
GITHUB_WORKSPACE="$(pwd)/AutoBuild-Actions"
GITHUB_ENV="${GITHUB_WORKSPACE}/AutoBuild-Action_ENV"
CONFIG_FILE="${GITHUB_WORKSPACE}/Configs/${COMPILE_ARCH}"
DEFAULT_SOURCE="coolsnowwolf/lede:master"
REPO_URL="https://github.com/$(cut -d \: -f 1 <<< ${DEFAULT_SOURCE})"
REPO_BRANCH=$(cut -d \: -f 2 <<< ${DEFAULT_SOURCE})

if [ ! -d AutoBuild-Actions ]; then
    git clone -b master https://github.com/xwings/AutoBuild-Actions-BETA AutoBuild-Actions
    cp CustomFiles/Depends/banner AutoBuild-Actions/CustomFiles/Depends/banner
fi

if [ ! -f ${CONFIG_FILE} ]; then
    echo "Target not found: $CONFIG_FILE"
    exit 1
fi

if [ -f ${CONFIG_FILE} ]; then
    echo "" >> ${CONFIG_FILE}
    echo "# CUSTOM PACKAGES" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_luci-proto-qmi=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_kmod-mii=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_kmod-usb-wdm=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_uqmi=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_iwlwifi-firmware-ax210=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_kmod-iwlwifi=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_avahi-utils=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_avahi-dbus-daemon=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_libavahi-dbus-support=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_wpad-mini=y" >> ${CONFIG_FILE}
    echo "CONFIG_LUCI_LANG_en=y" >> ${CONFIG_FILE}
    sed -i 's/^CONFIG_TARGET_ROOTFS_PARTSIZE=480/CONFIG_TARGET_ROOTFS_PARTSIZE=992/g' ${CONFIG_FILE}
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
    git clone -b master https://github.com/openwrt/openwrt.git originalwrt
    rm -rf openwrt/package/kernel/mac80211
    cp -aRp originalwrt/package/kernel/mac80211 openwrt/package/kernel/
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
make download -j$CPU_COUNT
make -j$CPU_COUNT

Firmware_Diy_End

if [ -f ${GITHUB_WORKSPACE}/openwrt/bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz ]; then
    cp ${GITHUB_WORKSPACE}/openwrt/bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz ${GITHUB_WORKSPACE}/xwingswrt-x86-64-$Compile_Date-BIOS-Full.img.gz
fi


