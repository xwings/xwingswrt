#
# settings.sh
#

# CPU_COUNT="$(cat /proc/cpuinfo | grep processor | wc -l)"
# DEFAULT_SOURCE="openwrt/openwrt:openwrt-24.10"
# DEFAULT_SOURCE="coolsnowwolf/lede:master"

LUCI_DEFAULT_LANG="en"
CPU_COUNT=4
DEFAULT_SOURCE="openwrt/openwrt"


# users/repo:branch:openwrt_package_location:kernel_config_options:additiona_post_git_function
ADD_PACKAGES="
                jerrykuku/luci-theme-argon:master:themes::
                jerrykuku/luci-app-argon-config:master:lean::
                :::PACKAGE_luci-proto-qmi=y:
                :::PACKAGE_kmod-mii=y:
                :::PACKAGE_kmod-usb-wdm=y:
                :::PACKAGE_uqmi=y:
                :::LUCI_LANG_en=y:
                :::FAT_DEFAULT_IOCHARSET=\"utf8\":
                :::PACKAGE_bash=y:
                vernesong/OpenClash:dev:other:PACKAGE_luci-app-openclash=y:OpenClash
"

TARGET_FIRMWARE_END="   
                        initramfs-kernel.bin
                        ext4-combined.img.gz
                        squashfs-combined.img.gz
                        ext4-combined-efi.img.gz
                        squashfs-combined-efi.img.gz
                        squashfs-sysupgrade.bin
                        squashfs-factory.ubi
                        "

OpenClash() {
    cp -aRp ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/${PACKAGE_NAME}/luci-app-openclash ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/
    rm -rf ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/${PACKAGE_NAME}/

    if grep -q "^CONFIG_TARGET_x86_64=y" ${OPENWRT_BASE}/.config; then
        XWINGSWRT_ARCH="x86_64"
    else
        XWINGSWRT_ARCH="aarch64"
    fi
    
    MIEMIETRON_URL="https://github.com/xwings/miemietron/releases/latest/download/miemietron-linux-${XWINGSWRT_ARCH}"

    mkdir -p ${BASE_FILES}/etc/openclash/core
    wget -O ${BASE_FILES}/etc/openclash/core/clash_meta "${MIEMIETRON_URL}"
    [ -s ${BASE_FILES}/etc/openclash/core/clash_meta ] || { echo "miemietron download failed"; exit 1; }
    chmod 4755 ${BASE_FILES}/etc/openclash/core/clash_meta

    VLESS_RS_URL="https://github.com/xwings/vless-rs/releases/latest/download/vless-rs-${XWINGSWRT_ARCH}"

    mkdir -p ${BASE_FILES}/usr/bin
    wget -O ${BASE_FILES}/usr/bin/vless-rs "${VLESS_RS_URL}"
    [ -s ${BASE_FILES}/usr/bin/vless-rs ] || { echo "vless-rs download failed"; exit 1; }
    chmod 4755 ${BASE_FILES}/usr/bin/vless-rs

    OPENCLASH_CORE_SH="${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/luci-app-openclash/root/usr/share/openclash/openclash_core.sh"

    sed -i '/^CPU_MODEL=$(uci_get_config "core_version")/a\
[ "$(uname -m)" = "aarch64" ] && XWINGSWRT_ARCH="arm64" || XWINGSWRT_ARCH="amd64"\
CPU_MODEL="miemietron-${XWINGSWRT_ARCH}"' ${OPENCLASH_CORE_SH}

    sed -i 's|DOWNLOAD_URL=".*clash-\${CPU_MODEL}\.tar\.gz"|DOWNLOAD_URL="https://github.com/xwings/miemietron/releases/latest/download/miemietron-linux-${XWINGSWRT_ARCH}"|g' ${OPENCLASH_CORE_SH}

    sed -i 's|if \[ ! -f "/tmp/clash_last_version" \]; then|if false; then|' ${OPENCLASH_CORE_SH}

    sed -i 's#if \[ "\$CORE_CV" != "\$CORE_LV" \] || \[ -z "\$CORE_CV" \]; then#if true; then#' ${OPENCLASH_CORE_SH}

    sed -i 's|gzip -t "\$DOWNLOAD_FILE" >/dev/null 2>&1|true|' ${OPENCLASH_CORE_SH}

    sed -i 's|tar zxvfo "\$DOWNLOAD_FILE" -C /tmp >/dev/null 2>&1|cp "\$DOWNLOAD_FILE" /tmp/clash >/dev/null 2>\&1|' ${OPENCLASH_CORE_SH}
}
