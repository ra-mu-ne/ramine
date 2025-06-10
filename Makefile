# Variables
QEMU = qemu-system-x86_64
LB = lb
ISO_FILE = ramine-amd64.hybrid.iso
CONFIG_DIR = config/
AUTO_DIR = auto/

# QEMU options
QEMU_OPTS = -enable-kvm \
           -cpu host \
           -smp cores=6,threads=2 \
           -m 4096 \
           -boot d \
           -netdev user,id=net0 \
           -device virtio-net,netdev=net0

# Phony targets
.PHONY: clean qemu help check-sudo all

# Default target
all: $(ISO_FILE)

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Build ISO file (default)"
	@echo "  clean   - Clean build artifacts"
	@echo "  qemu    - Run QEMU with the built ISO"
	@echo "  help    - Show this help message"

# Check sudo privileges
check-sudo:
	@if [ "$$(id -u)" -ne 0 ] && ! sudo -n true 2>/dev/null; then \
		echo "This target requires sudo privileges"; \
		exit 1; \
	fi

# Clean target
clean: check-sudo
	sudo $(LB) clean
	rm -f $(ISO_FILE)
	@echo "Clean completed"

# Create auto directory from config
$(AUTO_DIR): $(CONFIG_DIR) | check-sudo
	sudo $(LB) config
	@touch $(AUTO_DIR)
	@echo "Configuration completed"

# Build ISO file
$(ISO_FILE): $(AUTO_DIR) | check-sudo
	sudo $(LB) build
	@test -f $@ || (echo "Build failed: $@ not created" && exit 1)
	@echo "ISO build completed: $@"

# Run QEMU
qemu: $(ISO_FILE)
	@echo "Starting QEMU..."
	$(QEMU) -drive file=$(ISO_FILE),media=cdrom $(QEMU_OPTS)

