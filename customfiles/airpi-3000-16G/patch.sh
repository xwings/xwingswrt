EnablePatch() {
    cp ../customfiles/airpi-3000-16G/dts/* lede/target/linux/mediatek/dts/
    echo "" >> lede/target/linux/mediatek/image/filogic.mk
    echo "
define Device/airpi-3000-16G
    DEVICE_VENDOR := Airpi
    DEVICE_MODEL := Airpi-3000-16G
    DEVICE_DTS := mt7981b-airpi-3000-16G
    DEVICE_DTS_DIR := ../dts
    DEVICE_PACKAGES := kmod-mt7981-firmware mt7981-wo-firmware kmod-hwmon-pwmfan kmod-usb3
    UBINIZE_OPTS := -E 5
    BLOCKSIZE := 128k
    PAGESIZE := 2048
    KERNEL_IN_UBI := 1
    IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += airpi-3000-16G
    " >> lede/target/linux/mediatek/image/filogic.mk
}