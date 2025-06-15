#!/bin/bash

qemu-system-x86_64 \
    -machine q35 \
    -enable-kvm \
    -cpu host \
    -smp 6 \
    -m 4G \
    -device ich9-intel-hda,id=sound0 \
    -device hda-duplex,bus=sound0.0 \
    -netdev user,id=net0 \
    -device virtio-net,netdev=net0 \
    -cdrom ramine-amd64.hybrid.iso \
    -boot d

