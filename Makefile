export TOP_DIR:=$(shell pwd)
export BUILD_DIR:=$(TOP_DIR)/build

all:
	if ! [ -d build ]; then mkdir build; fi
	./scripts/linux.build
	./scripts/qemu.build
	./scripts/rootfs.build
	./scripts/busybox.build
	./scripts/fixetc.build
clean:
	rm -rf build
	rm -rf rootfs*
