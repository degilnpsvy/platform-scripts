./software/bin/qemu-system-i386 -kernel ./build/linux-build/arch/i386/boot/bzImage -hda rootfs.img -append "root=/dev/sda init=/bin/ash rw" -monitor stdio
