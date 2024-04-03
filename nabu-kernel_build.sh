git clone https://github.com/map220v/sm8150-mainline.git --branch nabu-$1 --depth 1 linux
cd linux
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig sm8150.config
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
_kernel_version="$(make kernelrelease -s)"
mkdir ../linux-xiaomi-nabu/boot
cp arch/arm64/boot/Image.gz ../linux-xiaomi-nabu/boot/vmlinuz-$_kernel_version
cp arch/arm64/boot/dts/qcom/sm8150-xiaomi-nabu.dtb ../linux-xiaomi-nabu/boot/dtb-$_kernel_version
sed -i "s/Version:.*/Version: ${_kernel_version}/" ../linux-xiaomi-nabu/DEBIAN/control
rm -rf ../linux-xiaomi-nabu/lib
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=../linux-xiaomi-nabu modules_install
rm ../linux-xiaomi-nabu/lib/modules/**/build
cd ..
rm -rf linux

dpkg-deb --build --root-owner-group linux-xiaomi-nabu
dpkg-deb --build --root-owner-group firmware-xiaomi-nabu
dpkg-deb --build --root-owner-group alsa-xiaomi-nabu
