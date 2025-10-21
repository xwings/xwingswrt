EnablePatch() {
    if [ "$KERNEL_CONFIG" == "custom_zyxel_ex5700" ] && [ "$REPO_USER" != "openwrt" ] && [ "$REPO_NAME" != "openwrt" ]; then
        git clone -b main --single-branch --depth 1 https://github.com/openwrt/openwrt.git openwrt
        # deps for custom dts
        cp openwrt/target/linux/mediatek/image/filogic.mk lede/target/linux/mediatek/image/filogic.mk
        cp openwrt/package/boot/uboot-envtools/files/mediatek_filogic lede/package/boot/uboot-envtools/files/mediatek_filogic
        cp openwrt/target/linux/mediatek/dts/* lede/target/linux/mediatek/dts/
        cp openwrt/target/linux/mediatek/image/filogic.mk lede/target/linux/mediatek/image/filogic.mk
        # add custom dts
        cp ../config/custom_zyxel_ex5700/dts/* lede/target/linux/mediatek/dts/
        # add mt7986_eeprom_mt7975_dual.bin & /mt7986_eeprom_mt7976.bin
        sed -i '/mt7986_wo_1.bin/a \\t\t$(PKG_BUILD_DIR)/mediatek/mt7916_eeprom.bin \\' lede/package/firmware/linux-firmware/mediatek.mk
    fi
}