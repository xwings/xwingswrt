#!/bin/bash -e

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib

while getopts ":c:r:d:p:" opt; do
  case $opt in
    c) config_out="$OPTARG"
    ;;
    r) repo_out="$OPTARG"
    ;;
    d) debug_out="$OPTARG"
    ;;
    p) pre_down="$OPTARG"
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
PRE_DOWNLOAD=$pre_down
CODE_WORKSPACE="$(pwd)"
PRE_DOWNLOAD_PATH="${CODE_WORKSPACE}/${PRE_DOWNLOAD}"
BUILD_WORKSPACE="${CODE_WORKSPACE}/build"
CONFIG_FILE="${BUILD_WORKSPACE}/config/${KERNEL_CONFIG}/${KERNEL_CONFIG}"

source ${CODE_WORKSPACE}/settings.sh

if [ ! -z $repo_out ]; then
    DEFAULT_SOURCE=$repo_out
fi

REPO_NAME="$(cut -d \: -f 1 <<< ${DEFAULT_SOURCE} | cut -d \/ -f 2)"
REPO_USER="$(cut -d \: -f 1 <<< ${DEFAULT_SOURCE} | cut -d \/ -f 1)"
REPO_URL="https://github.com/$(cut -d \: -f 1 <<< ${DEFAULT_SOURCE})"
REPO_BRANCH=$(cut -d \: -f 2 <<< ${DEFAULT_SOURCE})
OPENWRT_BASE="${BUILD_WORKSPACE}/${REPO_NAME}"
UCI_DEFAULT_CONFIG="${OPENWRT_BASE}/package/lean/default-settings/files/zzz-default-settings"
UCI_BASE_CONFIG="${OPENWRT_BASE}/package/feeds/luci/luci-base/root/etc/uci-defaults/luci-base"
BASE_FILES="${OPENWRT_BASE}/package/base-files/files"
FEEDS_LUCI="${OPENWRT_BASE}/package/feeds/luci"
FEEDS_PKG="${OPENWRT_BASE}/package/feeds/packages"
BUILD_DATE="$(date +%Y%m%d)"
BASEONLY="$base_only"
LUCI_DEFAULT_LANG="$(echo $LUCI_DEFAULT_LANG | awk '{print tolower($0)}')"

fn_exists() { [ `type -t $1`"" == 'function' ]; }

if [ -z ${KERNEL_CONFIG} ]; then
    echo "Error!!! Config [$KERNEL_CONFIG] not found, usage ./build.sh -c x86_64"
    exit 1
fi

if [ ! -d ${BUILD_WORKSPACE}/config ]; then
    mkdir -p ${BUILD_WORKSPACE}/config
    cp -aRp ${CODE_WORKSPACE}/config/*  ${BUILD_WORKSPACE}/config
    cat ${BUILD_WORKSPACE}/config/depends/general_config >> $CONFIG_FILE
fi

if [ ! -f ${CONFIG_FILE} ]; then
    echo "Error!!! Config not found: ${CONFIG_FILE}"
    exit 1
fi

if [ -z ${PRE_DOWNLOAD} ]; then
    for p in ${DEL_PACKAGES}; do
        sed -i "/${p}/d" ${CONFIG_FILE}
    done
    unset p

    for p in ${ADD_PACKAGES}; do
        PACKAGE_CONFIG=$(cut -d \: -f 4 <<< ${p})
        if [ ! -z ${PACKAGE_CONFIG} ]; then
            if  ! grep -q "${PACKAGE_CONFIG}" "${CONFIG_FILE}" ; then
                echo "CONFIG_${PACKAGE_CONFIG}" >> ${CONFIG_FILE}
            fi
        fi
    done
    unset p

    cd ${BUILD_WORKSPACE}
    if [ ! -d ${OPENWRT_BASE} ]; then
        git clone -b ${REPO_BRANCH} --single-branch --depth 1 ${REPO_URL}.git ${REPO_NAME}
    fi

    if [ -f ../config/${KERNEL_CONFIG}/patch.sh ]; then
        source ../config/${KERNEL_CONFIG}/patch.sh
        EnablePatch
    fi
elif [ ! -z ${PRE_DOWNLOAD} ] && [ -d ${PRE_DOWNLOAD_PATH} ]; then
    if [ -d ${OPENWRT_BASE} ]; then
        rm -rf ${OPENWRT_BASE}
    fi
    cd ${BUILD_WORKSPACE}
    cp -aRp ${PRE_DOWNLOAD_PATH} ${OPENWRT_BASE}
    cd ${OPENWRT_BASE}
    make clean
else
    echo "Error!!! Pre download folder not found"
    exit 1
fi

cd ${OPENWRT_BASE}
./scripts/feeds update -a
./scripts/feeds install -a -p ipv6
./scripts/feeds install -a

if [ -z ${PRE_DOWNLOAD} ]; then
    if [ -f ${UCI_DEFAULT_CONFIG} ]; then
        if [ ! -z "$LUCI_DEFAULT_LANG" ]; then
            sed -i "s/luci.main.lang=/luci.main.lang=${LUCI_DEFAULT_LANG}/g" ${UCI_DEFAULT_CONFIG}
        fi    
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

    cp ${CODE_WORKSPACE}/config/depends/banner ${BASE_FILES}/etc
    sed -i "s?/bin/login?/usr/libexec/login.sh?g" ${FEEDS_PKG}/ttyd/files/ttyd.config
    sed -i -- 's:/bin/ash:'/bin/bash':g' ${BASE_FILES}/etc/passwd
    cp ${CONFIG_FILE} ${OPENWRT_BASE}/.config
    make defconfig
    rm -f .config && cp ${CONFIG_FILE} ${OPENWRT_BASE}/.config
    rm -r ${FEEDS_LUCI}/luci-theme-argon* 2>&1 || true

    for p in $ADD_PACKAGES; do
        PACKAGE_SOURCE=$p
        PACKAGE_NAME="$(cut -d \: -f 1 <<< ${PACKAGE_SOURCE} | cut -d \/ -f 2)"
        PACKAGE_URL="https://github.com/$(cut -d \: -f 1 <<< ${PACKAGE_SOURCE})"
        PACKAGE_BRANCH=$(cut -d \: -f 2 <<< ${PACKAGE_SOURCE})
        PACKAGE_LOCATION=$(cut -d \: -f 3 <<< ${PACKAGE_SOURCE})
        PACKAGE_ADDON=$(cut -d \: -f 5 <<< ${PACKAGE_SOURCE})

        if [ ! -z $PACKAGE_NAME ]; then
            git clone -b ${PACKAGE_BRANCH} --single-branch --depth 1 ${PACKAGE_URL} ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/${PACKAGE_NAME}
        fi
        
        if fn_exists $PACKAGE_ADDON; then
            ${PACKAGE_ADDON}
        fi
    done
    unset p
fi

./scripts/feeds install -a
make defconfig
make download -j$CPU_COUNT

cd ${OPENWRT_BASE}

if [ "$debug_out" == 1 ]; then
    make -j1 V=sc
else
    make -j$CPU_COUNT V=s
fi

if [ ! -d ${BUILD_WORKSPACE}/firmware ]; then
    mkdir -p ${BUILD_WORKSPACE}/firmware
fi

cd ${OPENWRT_BASE}/bin/targets
BIN_ARCH="$(find . | grep sha256sum | awk -F \/ '{print $2}')"
BIN_MODEL="$(find . | grep sha256sum | awk -F \/ '{print $3}')"

for e in ${TARGET_FIRMWARE_END}; do
    TARGET_FIRMWARE="$(ls ${OPENWRT_BASE}/bin/targets/$BIN_ARCH/$BIN_MODEL/openwrt-$BIN_ARCH-$BIN_MODEL*${e} 2>&1 || true)"
    if [ ! -z "$TARGET_FIRMWARE" ] && [ -f "$TARGET_FIRMWARE" ]; then
        echo "Found $TARGET_FIRMWARE"
        SHA256_END="$(sha256sum ${TARGET_FIRMWARE} | awk '{print $1}' | cut -c1-5)"
        cp ${TARGET_FIRMWARE} ${BUILD_WORKSPACE}/firmware/xwingswrt-$KERNEL_CONFIG-$BUILD_DATE-Full-$SHA256_END-${e}
    fi  
done
unset e 