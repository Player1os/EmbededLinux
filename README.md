# EmbededLinuxMediaPlayer

This project uses buildroot to create a custom linux image for the arm architecture to run in a qemu virtual machine.
Once loaded and running, the os reacts to a usb storage device being plugged, by automatically mounting it and playing all mp3 files found on it.

## Included Scripts

### build.sh

Creates the linux kernel and rootfs images, in the following steps:

1. Downloads a clone of the most recent version of buildroot from the official repository.
2. Copies and loads the prepared defconfig files into the buildroot project (for more details on how they were created, please read below).
3. Runs the buildroot project's makefile to create an initial version of the linux kernel and rootfs images.
4. Copies prepared files to be included in the os (for a detailed description of the files and their purpose, please read below).
5. Reruns the buildroot project's makefile to include these files in the rootfs image.
6. Deletes the buildroot project, perserving only the created images.

### usb.sh

Creates a usb image for testing, in the following steps. The image will contain all the files curently within the `usb` folder.

*Note that this script requires root privilages to run*

1. Allocates 100MB of data to be used for the image.
2. Formats the allocated file using the default filesystem used by `mkfs`.
3. `Root privilages required` Mounts the filesystem to a temporary directory and copies all the contents of the `usb` folder into it.
4. `Root privilages required` Unmounts the filesystem and deletes the temporary directory.

### test.sh

Contains the exact command used by the developer to load the kernel and rootfs images into the qemu virtual machine.

## Buildroot Defconfig

To create the buildroot configs, first the defconfig `qemu_arm_versatile_defconfig` (which is included in the buildroot repository) was loaded.

The following modifications were made in `make menuconfig`:
- System Configuration -> /dev managment  (Dynamic using devtmpfs + mdev)
- Toolchain -> Toolchain type (External toolchain) *[here a random external toolchain was chosen]*
- Kernel -> Kernel configuration (Using a custom (def)config file) -> `(board/qemu/arm-versatile/mediaplayer.config)`
- Target packages -> Audio and Video applications -> 
```
[*] alsa-utils
  [*]alsa mixer
[*]mpg123
```

The following modifications were made in `make linux-menuconfig`:
- Device Drivers ->
```
[*] USB support ->
  <*> Support for Host-side USB
  <*>   OHCI HCD (USB 1.1) Support
  <*>   USB Mass Storage support
```

The modified defconfig files can be found in the `configs` directory of this project.

## Rootfs Modifications

The following files can be found in the `files` directory of this project.

### /etc/init.d/S47sound

Initializes the module that enables sound playback in the guest VM on os startup.

### /etc/mdev.conf

The configuration file for mdev that specifies which script should be run when a device is added/removed under `/dev/`.

### /lib/mdev/usbautomount

The script that is run each time a device with the prefix `sd` is added/removed under `/dev/` (as is specified in `/etc/mdev.conf`).

The script reacts only to devices added after os initialization and properly mounts/unmounts the detected device under `/media/` in a directory corresponding to the device's name under `/dev/`.

When mounted the device is searched for any `.mp3` files, which are then played using `mpg123` in random order.

## How to test it?

The simplest way to test this project is to first run all three scripts `build.sh`, `usb.sh` and `test.sh`, in the specified order.

After the guest os finishes booting you should login as `root` (no password is required) and add the image created by `usb.sh` into the qemu VM as a usb device. This can be achieved by first entering the qemu console `Ctrl+A C` and entering the command `usb_add disk:usb.img`. The newly detected usb device should be automatically mounted and you should hear all the mp3 tracks contained in the usb image being played from within the qemu VM.
