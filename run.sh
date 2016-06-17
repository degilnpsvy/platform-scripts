./software/bin/qemu-system-i386 -kernel ./target/linux-build/arch/i386/boot/bzImage -hda ./target/rootfs.img -append "root=/dev/sda init=/bin/ash rw" -monitor stdio
