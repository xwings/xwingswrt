EnablePatch() {
# preparing files
    cp ../config/airpi-ap3000e/dts/*  ${OPENWRT_BASE}/target/linux/mediatek/dts/
    echo "" >> ${OPENWRT_BASE}/target/linux/mediatek/image/filogic.mk
    echo "
define Device/airpi-ap3000e
    DEVICE_VENDOR := Airpi
    DEVICE_MODEL := Airpi-AP3000E
    DEVICE_DTS := mt7981b-airpi-ap3000e
    DEVICE_DTS_DIR := ../dts
    DEVICE_PACKAGES :=kmod-mt7981-firmware mt7981-wo-firmware kmod-usb3 f2fsck mkf2fs
    UBINIZE_OPTS := -E 5
    BLOCKSIZE := 128k
    PAGESIZE := 2048
    KERNEL_IN_UBI := 1
    IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += airpi-ap3000e
    " >>  ${OPENWRT_BASE}/target/linux/mediatek/image/filogic.mk
    sed -i '/glinet,gl-mt6000)/i \\tairpi,ap3000e)\n\t\tlan_mac=$(macaddr_generate_from_mmc_cid mmcblk0)\n\t\twan_mac=$(macaddr_add "$lan_mac" 1)\n\t\t;;'  ${OPENWRT_BASE}/target/linux/mediatek/filogic/base-files/etc/board.d/02_network
    sed -i '/glinet,gl-mt3000/i \\tairpi,ap3000e|\\'  ${OPENWRT_BASE}/target/linux/mediatek/filogic/base-files/etc/board.d/02_network
    sed -i '/glinet,gl-mt6000|\\/i \\tairpi,ap3000e|\\'  ${OPENWRT_BASE}/target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh
    sed -i '/glinet,gl-mt6000|\\/i \\tairpi,ap3000e)\n\t\taddr=$(macaddr_generate_from_mmc_cid mmcblk0)\n\t\t[ "$PHYNBR" = "0" ] && macaddr_add $addr 2 > /sys${DEVPATH}/macaddress\n\t\t[ "$PHYNBR" = "1" ] && macaddr_add $addr 3 > /sys${DEVPATH}/macaddress\n\t\t;;' ${OPENWRT_BASE}/target/linux/mediatek/filogic/base-files/etc/hotplug.d/ieee80211/11_fix_wifi_mac
    sed -i '/mt7981-wo-firmware\/install/a \\tcp $(BUILD_DIR)/../../../config/airpi-ap3000e/firmware/mt7981_eeprom_mt7976_dbdc.bin $(PKG_BUILD_DIR)/mediatek\/mt7981_eeprom_mt7976_dbdc.bin' ${OPENWRT_BASE}/package/firmware/linux-firmware/mediatek.mk
    cp -aR ../config/airpi-ap3000e/Airpi-gpio-fan ${OPENWRT_BASE}/package/kernel/
    cp -aR ../config/airpi-ap3000e/luci-app-Airpifanctrl ${OPENWRT_BASE}/package/other/    
    sed -i '/mt7981_wo.bin/a \\t\t$(PKG_BUILD_DIR)/mediatek/mt7981_eeprom_mt7976_dbdc.bin \\' ${OPENWRT_BASE}/package/firmware/linux-firmware/mediatek.mk
}