# generic build steps

build/kernel: build/rootfs

define build/kernel
	$(call do/linux)
endef

define build/software
	$(call do/qemu)
endef

define build/rootfs
	$(call do/rootfs)
endef

define build/image
endef

define do/clean
	$(call PRINT, [CLEAN] clean target directory)
	$(call do/target/clean)
	$(call do/module/clean)
endef

define do/target/clean
	$(Q)$(call EXEC, rm -rf $(TARGET_DIR))
endef

define do/romfs/clean
	$(Q)$(call EXEC, rm -rf $(ROOTFS_DIR))
endef

# linux build steps

define do/module
	$(call do/module/prepare)
	$(call do/module/compile)
	$(call do/module/install)
endef

define do/module/compile
	$(call PRINT, [BUILD] building kernel module)
	$(Q)for d in $(wildcard $(MODULE_DIR)/*) ; do\
	if [ -d $${d} ] ; then echo $${d##*/}; $(call EXEC, $(MAKE) -C $${d} LINUX_DIR=$(LINUX_DIR) LINUX_BUILD_DIR=$(LINUX_BUILD_DIR)) ; fi;\
	done
endef

define do/module/install
	$(call PRINT, [ROMFS] install kernel module)
	$(Q)$(call EXEC, if ! [ -d $(ROOTFS_DIR)/module ]; then mkdir -p $(ROOTFS_DIR)/module; fi)
	$(Q)for d in $(wildcard $(MODULE_DIR)/*) ; do\
	if [ -d $${d} ] ; then echo $${d##*/}; \
	cp $${d}/*.ko $(ROOTFS_DIR)/module/ ; \
	fi; done
$(Q)#$(call EXEC, $(MAKE) -C $${d} LINUX_DIR=$(LINUX_DIR) LINUX_BUILD_DIR=$(LINUX_BUILD_DIR) INSTALL_MODULE_DIR=$(ROOTFS_DIR) install);
endef

define do/module/clean
	$(call PRINT, [CLEAN] clean kernel module)
	$(Q)$(call EXEC, if ! [ -d $(ROOTFS_DIR)/module ]; then mkdir -p $(ROOTFS_DIR)/module; fi)
	$(Q)for d in $(wildcard $(MODULE_DIR)/*) ; do\
	if [ -d $${d} ] ; then echo $${d##*/}; $(call EXEC, $(MAKE) -C $${d} clean); fi;\
	done

endef

define do/module/prepare
endef

define do/linux
	$(call do/linux/prepare)
	$(call do/linux/compile)
endef

define do/linux/compile
	$(call PRINT, [BUILD] building kernel vmlinux)
	$(Q)$(call EXEC, $(MAKE) -C $(LINUX_DIR) bzImage -j -l4 O=$(LINUX_BUILD_DIR) V=$(VERBOSE))
endef

define do/linux/prepare
	$(Q)$(call EXEC, if ! [ -d $(LINUX_BUILD_DIR) ]; then mkdir -p $(LINUX_BUILD_DIR); fi)
	$(Q)$(call EXEC, if ! [ -f $(LINUX_BUILD_DIR)/.config ]; then cp $(SCRIPT_DIR)/linux_config $(LINUX_BUILD_DIR)/.config; fi)
	$(Q)$(call EXEC, $(MAKE) -C $(LINUX_DIR) oldconfig O=$(LINUX_BUILD_DIR) V=$(VERBOSE))
	$(Q)$(call EXEC, $(MAKE) -C $(LINUX_DIR) scripts O=$(LINUX_BUILD_DIR) V=$(VERBOSE))
	$(Q)$(call EXEC, $(MAKE) -C $(LINUX_DIR) prepare O=$(LINUX_BUILD_DIR) V=$(VERBOSE))
endef

# qemu build steps

define do/qemu
	$(call do/qemu/prepare)
	$(call do/qemu/compile)
	$(call do/qemu/install)
endef

define do/qemu/compile
	$(call PRINT, [BUILD] building qemu)
	$(call do/qemu/config)
	$(Q)$(call EXEC, $(MAKE) -C $(QEMU_BUILD_DIR) -j -l4 V=$(QEMU_VERBOSE))
endef

define do/qemu/install
	$(call PRINT, [SOFTWARE] install qemu)
	$(Q)$(call EXEC, $(MAKE) -C $(QEMU_BUILD_DIR) install)
endef

define do/qemu/prepare
	$(Q)$(call EXEC, if ! [ -d $(QEMU_BUILD_DIR) ]; then mkdir -p $(QEMU_BUILD_DIR); fi)
endef

# rootfs build steps

define do/rootfs
	$(call do/rootfs/prepare)
	$(call do/busybox)
	$(call do/linux/prepare)
	$(call do/module)
endef

define do/rootfs/prepare	
	$(Q)$(call EXEC, if ! [ -d $(ROOTFS_DIR) ]; then mkdir -p $(ROOTFS_DIR); fi)
	$(Q)$(call EXEC, cp $(TOP_DIR)/scripts/romfs.txt $(TARGET_DIR)/romfs.txt)
endef

# busybox build steps

define do/busybox
	$(call do/busybox/prepare)
	$(call do/busybox/compile)
	$(call do/busybox/install)
endef

define do/busybox/prepare
	$(Q)$(call EXEC, if ! [ -d $(BUSYBOX_BUILD_DIR) ]; then mkdir -p $(BUSYBOX_BUILD_DIR); fi)
endef

define do/busybox/compile
	$(call PRINT, [BUILD] building busybox)
	$(Q)$(call EXEC, if ! [ -f $(BUSYBOX_BUILD_DIR)/.config ]; then cp $(SCRIPT_DIR)/busybox_config $(BUSYBOX_BUILD_DIR)/.config; fi)
	$(Q)$(call EXEC, $(MAKE) -C $(BUSYBOX_DIR) -j -l4 O=$(BUSYBOX_BUILD_DIR) V=$(VERBOSE))
endef

define do/busybox/install
	$(call PRINT, [ROMFS] install busybox)
	$(Q)$(call EXEC, make install -C $(BUSYBOX_DIR) CONFIG_PREFIX=$(ROOTFS_DIR) O=$(BUSYBOX_BUILD_DIR))
	$(Q)$(call EXEC, if ! [ -f $(ROOTFS_DIR)/init ]; then ln -s bin/busybox $(ROOTFS_DIR)/init; fi)
endef

# SYSTEM build steps

define do/build/prepare
	$(Q)$(call EXEC, if ! [ -d build ]; then mkdir $(TARGET_DIR); fi)
endef

# config steps
define do/config
	$(call do/linux/config)
	$(call do/qemu/config)
	$(call do/busybox/config)
endef

define do/linux/config
	$(call do/linux/prepare)
	$(Q)$(MAKE) -C $(LINUX_DIR) alldefconfig O=$(LINUX_BUILD_DIR)
	$(Q)$(MAKE) -C $(LINUX_DIR) menuconfig O=$(LINUX_BUILD_DIR)
endef

define do/qemu/config
	$(call do/qemu/prepare)
	$(Q)$(call EXEC,cd $(QEMU_BUILD_DIR) && $(QEMU_DIR)/configure --prefix=$(SOFTWARE_DIR) --target-list=i386-softmmu)
endef

define do/busybox/config
	$(call do/busybox/prepare)
	$(Q)$(call EXEC, $(MAKE) -C $(BUSYBOX_DIR) menuconfig O=$(BUSYBOX_BUILD_DIR))
endef

# other functions
define PRINT
	@echo $(1) '('`date +%r`')'
endef
