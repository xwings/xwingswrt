EnablePatch() {
    # preparing files
    cp ${BUILD_WORKSPACE}/config/${KERNEL_CONFIG}/bootcount ${OPENWRT_BASE}/target/linux/qualcommax/ipq807x/base-files/etc/init.d/bootcount
    cp ${BUILD_WORKSPACE}/config/${KERNEL_CONFIG}/ipq8071-ax3600.dts ${OPENWRT_BASE}/target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/ipq8071-ax3600.dts
}
