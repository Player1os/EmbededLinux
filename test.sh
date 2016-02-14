#!/bin/sh
qemu-system-arm \
  -M versatilepb \
  -nographic \
  -usb \
  -drive file=rootfs.img,if=scsi,format=raw \
  -kernel boot/zImage \
  -append "console=ttyAMA0, root=/dev/sda"