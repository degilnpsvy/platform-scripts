# generic build steps

define build/kernel
	$(call do/linux)
endef

define build/qemu
	$(call do/qemu)
endef

define build/rootfs
	$(call do/rootfs)
endef

define build/image
endef

define do/clean
	rm -rf $(TARGET_DIR)
endef

# config steps
define do/config
	$(call do/linux/config)
	$(call do/qemu/config)
	$(call do/busybox/config)
endef

define do/linux/config
	$(call do/linux/prepare)
	$(MAKE) -C $(LINUX_DIR) defconfig O=$(LINUX_BUILD_DIR)
	$(MAKE) -C $(LINUX_DIR) menuconfig O=$(LINUX_BUILD_DIR)
endef

define do/qemu/config
	$(call do/qemu/prepare)
	cd $(QEMU_BUILD_DIR) && $(QEMU_DIR)/configure --prefix=$(SOFTWARE_DIR) --target-list=i386-softmmu
endef

define do/busybox/config
	$(call do/busybox/prepare)
	$(MAKE) -C $(BUSYBOX_DIR) menuconfig O=$(BUSYBOX_BUILD_DIR)
endef
# linux build steps

define do/linux
	$(call do/linux/prepare)
	$(call do/linux/compile)
endef

define do/linux/compile
	if ! [ -f $(LINUX_BUILD_DIR)/.config ]; then cp $(SCRIPT_DIR)/linux_config $(LINUX_BUILD_DIR)/.config; fi
	$(MAKE) -C $(LINUX_DIR) bzImage -j -l4 O=$(LINUX_BUILD_DIR)
endef

define do/linux/prepare
	if ! [ -d $(LINUX_BUILD_DIR) ]; then mkdir -p $(LINUX_BUILD_DIR); fi
endef

# qemu build steps

define do/qemu
	$(call do/qemu/prepare)
	$(call do/qemu/compile)
	$(call do/qemu/install)
endef

define do/qemu/compile
	$(call do/qemu/config)
	$(MAKE) -C $(QEMU_BUILD_DIR) -j -l4
endef

define do/qemu/install
	$(MAKE) -C $(QEMU_BUILD_DIR) install
endef

define do/qemu/prepare
	if ! [ -d $(QEMU_BUILD_DIR) ]; then mkdir -p $(QEMU_BUILD_DIR); fi
endef

# rootfs build steps

define do/rootfs
	$(call do/rootfs/prepare)
	$(call do/rootfs/create)
	$(call do/rootfs/install_dirs)
	$(call do/busybox)
endef

define do/rootfs/prepare	
	if ! [ -d $(ROOTFS_DIR) ]; then mkdir -p $(ROOTFS_DIR); fi
endef

define do/rootfs/create
	dd if=/dev/zero of=$(TARGET_DIR)/rootfs.img bs=1M count=512
	mkfs.ext3 $(TARGET_DIR)/rootfs.img
endef

define do/rootfs/install_dirs
	$(call do/rootfs/mount)
	sudo mkdir -p $(ROOTFS_DIR)/{dev,proc,sys,etc}
	sudo bash -c "echo \"ttyS0::sysinit:/bin/ash\" > $(ROOTFS_DIR)/etc/inittable"
	$(call do/rootfs/umount)
endef

define do/rootfs/mount
	sudo mount -t ext3 -o loop $(TARGET_DIR)/rootfs.img $(ROOTFS_DIR)
endef

define do/rootfs/umount
	sudo umount $(ROOTFS_DIR)
endef

# busybox build steps

define do/busybox
	$(call do/busybox/prepare)
	$(call do/busybox/compile)
	$(call do/busybox/install)
endef

define do/busybox/prepare
	if ! [ -d $(BUSYBOX_BUILD_DIR) ]; then mkdir -p $(BUSYBOX_BUILD_DIR); fi
endef

define do/busybox/compile
	if ! [ -f $(BUSYBOX_BUILD_DIR)/.config ]; then cp $(SCRIPT_DIR)/busybox_config $(BUSYBOX_BUILD_DIR)/.config; fi
	$(MAKE) -C $(BUSYBOX_DIR) -j -l4 O=$(BUSYBOX_BUILD_DIR)
endef

define do/busybox/install
	$(call do/rootfs/mount)
	sudo make install -C $(BUSYBOX_DIR) CONFIG_PREFIX=$(ROOTFS_DIR) O=$(BUSYBOX_BUILD_DIR)
	$(call do/rootfs/umount)
endef

# SYSTEM build steps

define do/build/prepare
	if ! [ -d build ]; then mkdir $(TARGET_DIR); fi
endef

