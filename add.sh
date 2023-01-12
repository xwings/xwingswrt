# How to use this file:
# users/repo:branch:openwrt_package_location
#

ADD_PACKAGES="
                xiaorouji/openwrt-passwall:luci:passwall-luci
                xiaorouji/openwrt-passwall:packages:passwall-depends
                pymumu/luci-app-smartdns:lede:other
                iwrt/luci-app-ikoolproxy:main:other
                fw876/helloworld:master:other
                jerrykuku/luci-theme-argon:18.06:themes
                thinktip/luci-theme-neobird:main:themes
                jerrykuku/luci-app-argon-config:master:lean
                vernesong/OpenClash:dev:other
                "