#!/bin/sh
dd if=/dev/zero of=usb.img bs=512 count=200000
mke2fs usb.img
mkdir usb_tmp
sudo mount -t auto usb.img usb_tmp
sudo cp -a -p usb/. usb_tmp/
sudo umount usb_tmp
rm -r usb_tmp