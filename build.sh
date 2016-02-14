git clone git://git.buildroot.net/buildroot
cp configs/qemu_arm_mediaplayer_defconfig buildroot/configs/qemu_arm_mediaplayer_defconfig
cp configs/mediaplayer.config buildroot/board/qemu/arm-versatile/mediaplayer.config
make qemu_arm_mediaplayer_defconfig
make

cp -a -p files/. buildroot/output/target/
cd buildroot
make
cd ..

cp buildroot/output/images/rootfs.ext2 rootfs.img
mkdir boot
cp buildroot/output/images/zImage boot/zImage

rm -r buildroot