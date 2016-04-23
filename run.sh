./software/bin/qemu-system-x86_64 -kernel ./build/linux-build/arch/x86_64/boot/bzImage -hda rootfs.img -append "root=/dev/sda init=/bin/ash rw" -monitor stdio
