TOP_DIR := $(shell pwd)
TARGET_DIR := $(TOP_DIR)/target
SOFTWARE_DIR := $(TOP_DIR)/software

SCRIPT_DIR :=$(TOP_DIR)/scripts

LINUX_DIR := $(TOP_DIR)/linux
LINUX_BUILD_DIR := $(TARGET_DIR)/linux-build

QEMU_DIR := $(TOP_DIR)/qemu
QEMU_BUILD_DIR := $(TARGET_DIR)/qemu-build

BUSYBOX_DIR := $(TOP_DIR)/busybox
BUSYBOX_BUILD_DIR := $(TARGET_DIR)/busybox-build

ROOTFS_DIR := $(TARGET_DIR)/rootfs

TARGET := build/prepare build/kernel build/software build/rootfs build/image

include $(SCRIPT_DIR)/verbose.mk
include $(SCRIPT_DIR)/system.mk

all: $(TARGET)

.PHONY: $(TARGET) clean config menuconfig

$(TARGET):
	$($@)

clean:
	$(call do/clean)

config menuconfig:
	$(call do/config)

%:
	$(call do/$@)
