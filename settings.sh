#
# How to use this file:
# users/repo:branch:openwrt_package_location:kernel_config_options:additiona_post_git_function
#

LUCI_DEFAULT_LANG="EN"
#CPU_COUNT="$(cat /proc/cpuinfo | grep processor | wc -l) / 2"
CPU_COUNT=4

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
                iwrt/luci-app-ikoolproxy:main:other::
                vernesong/OpenClash:dev:other:PACKAGE_luci-app-openclash=y:OpenClash
"

# 
# Add a package name to remove from config
#
DEL_PACKAGES="
                adb
                serverchan
                pushbot
                docker
                DOCKER
                aliyundrive
                qbittorrent
                aria2
                unblockmusic
                UnblockNeteaseMusic
                uugamebooster
                uhttpd
                usb-printer
                syncdial
                vsftpd
                onliner
                nfs
                samba
                davfs2
                cifs
                passwall
    "

TARGET_FIRMWARE_END="   
                        initramfs-kernel.bin
                        ext4-combined.img.gz
                        squashfs-combined.img.gz
                        ext4-combined-efi.img.gz
                        squashfs-combined-efi.img.gz
                        sysupgrade.bin
                        "

OpenClash() {
    cp -aRp ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/${PACKAGE_NAME}/luci-app-openclash ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/
    rm -rf ${OPENWRT_BASE}/package/${PACKAGE_LOCATION}/${PACKAGE_NAME}/
}
