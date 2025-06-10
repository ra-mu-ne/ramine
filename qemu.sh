#!/bin/bash

qemu-system-x86_64 \
		-enable-kvm \
		-cpu host \
		-smp cores=6,threads=2 \
		-m 4096 \
		-drive file=ramine-amd64.hybrid.iso,media=cdrom \
		-boot d \
		-netdev user,id=net0 \
		-device virtio-net,netdev=net0

