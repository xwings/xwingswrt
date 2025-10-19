EnablePatch() {
    cp ../customfiles/airpi-ap3000e/dts/* lede/target/linux/mediatek/dts/
    echo "" >> lede/target/linux/mediatek/image/filogic.mk
    echo "
define Device/airpi-ap3000e
    DEVICE_VENDOR := Airpi
    DEVICE_MODEL := Airpi-AP3000E
    DEVICE_DTS := mt7981b-airpi-ap3000e
    DEVICE_DTS_DIR := ../dts
    DEVICE_PACKAGES := kmod-mt7915e kmod-mt7981-firmware mt7981-wo-firmware kmod-hwmon-pwmfan kmod-usb3
    UBINIZE_OPTS := -E 5
    BLOCKSIZE := 128k
    PAGESIZE := 2048
    KERNEL_IN_UBI := 1
    IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += airpi-ap3000e
    " >> lede/target/linux/mediatek/image/filogic.mk
    sed -i '/glinet,gl-mt6000)/i \    airpi,ap3000e)\n        lan_mac=$(macaddr_generate_from_mmc_cid mmcblk0)\n        wan_mac=$(macaddr_add "$lan_mac" 1)\n        ;;' lede/target/linux/mediatek/filogic/base-files/etc/board.d/02_network
    sed -i '/glinet,gl-mt3000/i \    airpi,ap3000e|\\' lede/target/linux/mediatek/filogic/base-files/etc/board.d/02_network
    sed -i '/glinet,gl-mt6000|\\/i \        airpi,ap3000e|\\' lede/target/linux/mediatek/filogic/base-files/lib/upgrade/platform.sh
    sed -i '/glinet,gl-mt6000|\\/i \        airpi,ap3000e|\\\n            addr=$(macaddr_generate_from_mmc_cid mmcblk0)\n            [ "$PHYNBR" = "0" ] && macaddr_add $addr 2 > /sys${DEVPATH}/macaddress\n            [ "$PHYNBR" = "1" ] && macaddr_add $addr 3 > /sys${DEVPATH}/macaddress\n            ;;' lede/target/linux/mediatek/filogic/base-files/etc/hotplug.d/ieee80211/11_fix_wifi_mac
}

sed -i '/pattern/a bananapi,bpi-r3|\' inputfile