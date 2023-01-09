#!/bin/bash

COMPILE_ARCH=$1
FIRMWARE_SPACE=$2
CPU_COUNT="$(cat /proc/cpuinfo | grep processor | wc -l)"
CODE_WORKSPACE="$(pwd)"
GITHUB_WORKSPACE="${CODE_WORKSPACE}/AutoBuild-Actions"
GITHUB_ENV="${GITHUB_WORKSPACE}/AutoBuild-Action_ENV"
CONFIG_FILE="${GITHUB_WORKSPACE}/Configs/${COMPILE_ARCH}"
DEFAULT_SOURCE="coolsnowwolf/lede:master"
REPO_URL="https://github.com/$(cut -d \: -f 1 <<< ${DEFAULT_SOURCE})"
REPO_BRANCH=$(cut -d \: -f 2 <<< ${DEFAULT_SOURCE})
UCI_DEFAULT_CONFIG="${GITHUB_WORKSPACE}/openwrt/package/lean/default-settings/files/zzz-default-settings"

if [ -z $COMPILE_ARCH ]; then
    echo "Ach not fined: ./build.sh x86_64"
    exit 1
fi

if [ ! -d AutoBuild-Actions ]; then
    git clone -b master https://github.com/xwings/AutoBuild-Actions-BETA AutoBuild-Actions
    cp CustomFiles/Depends/banner ${GITHUB_WORKSPACE}/CustomFiles/Depends/banner
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

    sed -i 's/^CONFIG_PACKAGE_luci-app-serverchan=y/# CONFIG_PACKAGE_luci-app-serverchan is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-pushbot=y/# CONFIG_PACKAGE_luci-app-pushbot is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-docker=y/# CONFIG_PACKAGE_luci-app-docker is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_DOCKER_CGROUP_OPTIONS=y/# CONFIG_DOCKER_CGROUP_OPTIONS is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_DOCKER_NET_MACVLAN=y/# CONFIG_DOCKER_NET_MACVLAN is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_DOCKER_OPTIONAL_FEATURES=y/# CONFIG_DOCKER_OPTIONAL_FEATURES is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_docker=y/# CONFIG_PACKAGE_docker is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_docker-compose=y/# CONFIG_PACKAGE_docker-compose is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-aliyundrive-webdav=y/# CONFIG_PACKAGE_luci-app-aliyundrive-webdav is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-qbittorrent=y/# CONFIG_PACKAGE_luci-app-qbittorrent is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-qbittorrent_static=y/# CONFIG_PACKAGE_luci-app-qbittorrent_static is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-aria2=y/# CONFIG_PACKAGE_luci-app-aria2 is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-unblockmusic=y/# CONFIG_PACKAGE_luci-app-unblockmusic is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-unblockmusic_INCLUDE_UnblockNeteaseMusic_Go=y/# CONFIG_PACKAGE_luci-app-unblockmusic_INCLUDE_UnblockNeteaseMusic_Go is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-uugamebooster=y/# CONFIG_PACKAGE_luci-app-uugamebooster is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-uhttpd=y/# CONFIG_PACKAGE_luci-app-uhttpd is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-usb-printer=y/# CONFIG_PACKAGE_luci-app-usb-printer is not set/g' ${CONFIG_FILE}
    sed -i 's/^CONFIG_PACKAGE_luci-app-syncdial=y/# CONFIG_PACKAGE_luci-app-syncdial is not set/g' ${CONFIG_FILE}

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

if [ -f ${UCI_DEFAULT_CONFIG} ]; then
    sed -i 's/^uci set luci.main.lang=zh_cn/uci set luci.main.lang=en/g' ${UCI_DEFAULT_CONFIG}
    sed -i 's/^exit 0/# Customized init.d/g' ${UCI_DEFAULT_CONFIG}
    echo "if [ -f /etc/init.d/tunnel ]; then /etc/init.d/tunnel enable ; fi" >> ${UCI_DEFAULT_CONFIG}
    echo "" >> ${UCI_DEFAULT_CONFIG}
    echo "exit 0" >> ${UCI_DEFAULT_CONFIG}
fi

if [ -d ${GITHUB_WORKSPACE}/openwrt/package/other/AutoBuild-Packages/luci-app-onliner ]; then
    cd ${GITHUB_WORKSPACE}/openwrt/package/other/AutoBuild-Packages/luci-app-onliner
    grep -rl "在线用户" . | xargs sed -i 's/在线用户/Active Users/g'
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

if [ -z $FIRMWARE_SPACE ]; then
    FIRMWARE_SPACE=${CODE_WORKSPACE}
fi

if [ ! -d $FIRMWARE_SPACE ]; then
    mkdir -p $FIRMWARE_SPACE
fi

cp ${GITHUB_WORKSPACE}/openwrt/bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz ${FIRMWARE_SPACE}/xwingswrt-x86-64-$Compile_Date-BIOS-Full.img.gz