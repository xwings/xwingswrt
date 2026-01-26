EnablePatch() {
# preparing files
    if [ -f ../config/gl-inet-mt3600be/mt7987a-glinet-gl-mt3600be.dts ]; then
        cp ../config/gl-inet-mt3600be/mt7987a-glinet-gl-mt3600be.dts ${OPENWRT_BASE}/target/linux/mediatek/dts/mt7987a-glinet-gl-mt3600be.dts
        echo "
define Device/glinet_gl-mt3600be
  DEVICE_VENDOR := GL.iNet
  DEVICE_MODEL := GL-MT3600BE
  DEVICE_DTS := mt7987a-glinet-gl-mt3600be
  DEVICE_DTS_DIR := ../dts
  DEVICE_DTC_FLAGS := --pad 4096
  DEVICE_DTS_LOADADDR := 0x4ff00000
  DEVICE_PACKAGES := mt7987-2p5g-phy-firmware kmod-mt7990-firmware kmod-hwmon-pwmfan
  UBINIZE_OPTS := -E 5
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += glinet_gl-mt3600be
    " >>  ${OPENWRT_BASE}/target/linux/mediatek/image/filogic.mk 
    sed -i '/mediatek,mt7986a-rfb)/i \\tglinet,gl-mt3600be)\n\t\tucidef_set_interfaces_lan_wan "eth1" eth0\n\t\t;;'  ${OPENWRT_BASE}/target/linux/mediatek/filogic/base-files/etc/board.d/02_network
    sed -i 'xiaomi,mi-router-ax3000t)/i \\tglinet,gl-mt3600be)\n\t\tethtool --set-eee eth0 eee on\n\t\tethtool --set-eee eth0 eee off\n\t\t;;' ${OPENWRT_BASE}target/linux/mediatek/filogic/base-files/etc/init.d/bootcount
    fi    
}
