#!/bin/bash

while getopts ":c:p:r:" opt; do
  case $opt in
    c) config_out="$OPTARG"
    ;;
    p) path_out="$OPTARG"
    ;;
    r) repo_out="$OPTARG"
    ;;    
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

KERNEL_CONFIG=$config_out
FIRMWARE_SPACE=$path_out
CPU_COUNT="$(cat /proc/cpuinfo | grep processor | wc -l)"
CODE_WORKSPACE="$(pwd)"
BUILD_WORKSPACE="${CODE_WORKSPACE}/build"
CONFIG_FILE="${BUILD_WORKSPACE}/config/${KERNEL_CONFIG}"
DEFAULT_SOURCE=$repo_out
if [ -z $DEFAULT_SOURCE ]; then
    DEFAULT_SOURCE="coolsnowwolf/lede:master"
fi
REPO_NAME="$(cut -d \: -f 1 <<< ${DEFAULT_SOURCE} | cut -d \/ -f 2)"
REPO_URL="https://github.com/$(cut -d \: -f 1 <<< ${DEFAULT_SOURCE})"
REPO_BRANCH=$(cut -d \: -f 2 <<< ${DEFAULT_SOURCE})
OPENWRT_BASE="${BUILD_WORKSPACE}/${REPO_NAME}"
UCI_DEFAULT_CONFIG="${OPENWRT_BASE}/package/lean/default-settings/files/zzz-default-settings"
UCI_BASE_CONFIG="${OPENWRT_BASE}/package/feeds/luci/luci-base/root/etc/uci-defaults/luci-base"
BASE_FILES="${OPENWRT_BASE}/package/base-files/files"
FEEDS_LUCI="${OPENWRT_BASE}/package/feeds/luci"
FEEDS_PKG="${OPENWRT_BASE}/package/feeds/packages"
BUILD_DATE="$(date +%Y%m%d%H%M)"

source ${CODE_WORKSPACE}/add.sh
source ${CODE_WORKSPACE}/del.sh

if [ -z $KERNEL_CONFIG ]; then
    echo "Config [$KERNEL_CONFIG] not found, usage ./build.sh -c x86_64"
    exit 1
fi

if [ ! -d ${BUILD_WORKSPACE}/config ]; then
    mkdir -p ${BUILD_WORKSPACE}/config
    cp ${CODE_WORKSPACE}/config/*  ${BUILD_WORKSPACE}/config
fi

if [ ! -f ${CONFIG_FILE} ]; then
    echo "Config not found: ${CONFIG_FILE}"
    exit 1
fi

if [ -f ${CONFIG_FILE} ]; then
    echo "" >> ${CONFIG_FILE}
    echo "# CUSTOM PACKAGES" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_luci-proto-qmi=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_kmod-mii=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_kmod-usb-wdm=y" >> ${CONFIG_FILE}
    echo "CONFIG_PACKAGE_uqmi=y" >> ${CONFIG_FILE}
    echo "CONFIG_LUCI_LANG_en=y" >> ${CONFIG_FILE}
    echo "CONFIG_FAT_DEFAULT_IOCHARSET=\"utf8\"" >> ${CONFIG_FILE}

    for p in $DEL_PACKAGES; do
        sed -i "/${p}/d" ${CONFIG_FILE}
    done
    unset p
fi

cd ${BUILD_WORKSPACE}
if [ ! -d ${BUILD_WORKSPACE}/${REPO_NAME} ]; then
    git clone -b ${REPO_BRANCH} --single-branch --depth 1 ${REPO_URL}.git
fi

cd ${BUILD_WORKSPACE}
if [ $KERNEL_CONFIG == "x86_64" ]; then
    git clone -b master https://github.com/openwrt/openwrt.git openwrt
    rm -rf ${OPENWRT_BASE}/package/kernel/mac80211
    cp -aRp openwrt/package/kernel/mac80211 ${OPENWRT_BASE}/package/kernel/    
fi

cd ${OPENWRT_BASE}
./scripts/feeds update -a
./scripts/feeds install -a

if [ -f ${UCI_DEFAULT_CONFIG} ]; then
    sed -i 's/luci.main.lang=zh_cn/luci.main.lang=en/g' ${UCI_DEFAULT_CONFIG} ${UCI_BASE_CONFIG}
    sed -i 's/^exit 0/# Customized init.d/g' ${UCI_DEFAULT_CONFIG}
    echo "if [ -f /etc/init.d/tunnel ]; then /etc/init.d/tunnel enable ; fi" >> ${UCI_DEFAULT_CONFIG}
    echo "" >> ${UCI_DEFAULT_CONFIG}
    cat >> ${UCI_DEFAULT_CONFIG} <<EOF
        sed -i '/check_signature/d' /etc/opkg.conf
        if [ -z "\$(grep "REDIRECT --to-ports 53" /etc/firewall.user 2> /dev/null)" ]; then
	        echo '# iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53' >> /etc/firewall.user
	        echo '# iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53' >> /etc/firewall.user
	        echo '# [ -n "\$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53' >> /etc/firewall.user
	        echo '# [ -n "\$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53' >> /etc/firewall.user
        fi
EOF
    echo "exit 0" >> ${UCI_DEFAULT_CONFIG}
fi

cp ${CODE_WORKSPACE}/customfiles/depends/banner ${BASE_FILES}/etc
sed -i "s?/bin/login?/usr/libexec/login.sh?g" ${FEEDS_PKG}/ttyd/files/ttyd.config
sed -i -- 's:/bin/ash:'/bin/bash':g' ${BASE_FILES}/etc/passwd
cp ${CONFIG_FILE} ${OPENWRT_BASE}/.config
make defconfig
rm -f .config && cp ${CONFIG_FILE} ${OPENWRT_BASE}/.config
rm -r ${FEEDS_LUCI}/luci-theme-argon*

for p in $ALL_PACKAGES; do
    PACKAGE_SOURCE=$p
    PACKAGE_NAME="$(cut -d \: -f 1 <<< ${PACKAGE_SOURCE} | cut -d \/ -f 2)"
    PACKAGE_URL="https://github.com/$(cut -d \: -f 1 <<< ${PACKAGE_SOURCE})"
    PACKAGE_BRANCH=$(cut -d \: -f 2 <<< ${PACKAGE_SOURCE})
    PACKAGE_LOCATION=$(cut -d \: -f 3 <<< ${PACKAGE_SOURCE})
    
    git clone -b ${PACKAGE_BRANCH} --single-branch --depth 1 ${PACKAGE_URL} ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/${PACKAGE_NAME}

    if [ $PACKAGE_NAME == "OpenClash" ]; then
        cp -aRp ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/${PACKAGE_NAME}/luci-app-openclash ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/
        rm -rf ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/${PACKAGE_NAME}/
    fi
done
unset p

./scripts/feeds install -a
make defconfig
make download -j$CPU_COUNT
make -j$CPU_COUNT

if [ ! -d $FIRMWARE_SPACE ]; then
    mkdir -p $FIRMWARE_SPACE
fi

if [ ! -d ${BUILD_WORKSPACE}/firmware ]; then
    mkdir -p ${BUILD_WORKSPACE}/firmware
fi

cd ${OPENWRT_BASE}/bin/targets
BIN_ARCH="$(find . | grep sha256sum | awk -F \/ '{print $2}')"
BIN_MODEL="$(find . | grep sha256sum | awk -F \/ '{print $3}')"

if [ $BIN_ARCH == "x86" ]; then
    TARGET_FIRMWARE_BIOS_END="combined.img.gz"
    TARGET_FIRMWARE_EFI_END="combined-efi.img.gz"
    TARGET_FIRMWARE_BIOS="$(ls ${OPENWRT_BASE}/bin/targets/$BIN_ARCH/$BIN_MODEL/openwrt-$BIN_ARCH-$BIN_MODEL*$TARGET_FIRMWARE_BIOS_END)" 
    TARGET_FIRMWARE_EFI="$(ls ${OPENWRT_BASE}/bin/targets/$BIN_ARCH/$BIN_MODEL/openwrt-$BIN_ARCH-$BIN_MODEL*$TARGET_FIRMWARE_EFI_END)"
    FIRMWARE_LIST=($TARGET_FIRMWARE_BIOS $TARGET_FIRMWARE_EFI)
    FIRMWARE_LIST_END=($TARGET_FIRMWARE_BIOS_END $TARGET_FIRMWARE_EFI_END)
else
    TARGET_FIRMWARE_END="sysupgrade.bin"
    TARGET_FIRMWARE="$(ls ${OPENWRT_BASE}/bin/targets/$BIN_ARCH/$BIN_MODEL/openwrt-$BIN_ARCH-$BIN_MODEL*$TARGET_FIRMWARE_END)"
    FIRMWARE_LIST=($TARGET_FIRMWARE)
    FIRMWARE_LIST_END=($TARGET_FIRMWARE_END)    
fi

i=0
for a in ${FIRMWARE_LIST[@]}; do
    SHA256_END="$(sha256sum ${FIRMWARE_LIST[$i]} | awk '{print $1}' | cut -c1-5)"
    cp ${FIRMWARE_LIST[$i]} ${BUILD_WORKSPACE}/firmware/xwingswrt-$KERNEL_CONFIG-$BUILD_DATE-Full-$SHA256_END-${FIRMWARE_LIST_END[$i]}
    i=$(($i + 1))
done    

if [ -z $GITHUB_ACTION ] && [ ! -z $FIRMWARE_SPACE ]; then
    cp ${BUILD_WORKSPACE}/firmware/* ${FIRMWARE_SPACE}
fi