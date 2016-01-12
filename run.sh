./software/bin/qemu-system-x86_64 -kernel ./linux/arch/x86/boot/bzImage -hda rootfs.img -append "root=/dev/sda init=/bin/ash rw" -monitor stdio
