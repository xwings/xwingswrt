#
# How to use this file:
# users/repo:branch:openwrt_package_location:kernel_config_options
#

ADD_PACKAGES="
                xiaorouji/openwrt-passwall:luci:passwall-luci:
                xiaorouji/openwrt-passwall:packages:passwall-depends:
                pymumu/luci-app-smartdns:lede:other:
                iwrt/luci-app-ikoolproxy:main:other:
                fw876/helloworld:master:other:
                jerrykuku/luci-theme-argon:18.06:themes:
                thinktip/luci-theme-neobird:main:themes:
                jerrykuku/luci-app-argon-config:master:lean:
                vernesong/OpenClash:dev:other:PACKAGE_luci-app-openclash=y
                :::PACKAGE_luci-proto-qmi=y
                :::PACKAGE_kmod-mii=y
                :::PACKAGE_kmod-usb-wdm=y
                :::PACKAGE_uqmi=y
                :::LUCI_LANG_en=y
                :::FAT_DEFAULT_IOCHARSET=\"utf8\"
                :::PACKAGE_bash=y
                "

# 
# Add a package name to remove from config
# Either,
#   i. Delete/comment from config
#   ii. Add the package name in del.sh
#

DEL_PACKAGES="
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
    "