git clone https://github.com/map220v/sm8150-mainline.git --branch nabu-$1 --depth 1 linux
cd linux
sed -i 'CONFIG_CMDLINE="quiet splash"' ./arch/arm64/configs/sm8150.config
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig sm8150.config
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
mkdir ../linux-xiaomi-nabu/boot
cp arch/arm64/boot/Image.gz ../linux-xiaomi-nabu/boot/vmlinuz-$2.0-sm8150
cp arch/arm64/boot/dts/qcom/sm8150-xiaomi-nabu.dtb ../linux-xiaomi-nabu/boot/dtb-$2.0-sm8150
rm -rf ../linux-xiaomi-nabu/lib
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=../linux-xiaomi-nabu modules_install
rm ../linux-xiaomi-nabu/lib/modules/**/build
cd ..
rm -rf linux

dpkg-deb --build --root-owner-group linux-xiaomi-nabu
dpkg-deb --build --root-owner-group firmware-xiaomi-nabu
dpkg-deb --build --root-owner-group alsa-xiaomi-nabu
