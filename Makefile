QEMU = qemu-system-x86_64
LB = lb
ISO_FILE = ramine-amd64.hybrid.iso

.PHONY: clean qemu help

# Default target
all: $(ISO_FILE)

help:
	@echo "Available targets:"
	@echo "  all     - Build ISO file (default)"
	@echo "  clean   - Clean build artifacts"
	@echo "  qemu    - Run QEMU with the built ISO"
	@echo "  help    - Show this help message"

clean:
	sudo $(LB) clean
	rm -f $(ISO_FILE)

# Check if we need to run lb config by looking at chroot directory
chroot: config/*
	sudo $(LB) config --bootappend-live "boot=live components locales=ja_JP.UTF-8"

# ISO depends on chroot being set up
$(ISO_FILE): chroot
	sudo $(LB) build

with-qemu: $(ISO_FILE)
	$(QEMU) \
		-enable-kvm \
		-cpu host \
		-smp cores=6,threads=2 \
		-m 4096 \
		-drive file=$(ISO_FILE),media=cdrom \
		-boot d \
		-netdev user,id=net0 \
		-device virtio-net,netdev=net0

