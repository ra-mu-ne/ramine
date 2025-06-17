#!/bin/bash


VM_DIR="./vm"
DISK_FILE="$VM_DIR/vm-disk.qcow2"


if [[ ! -d "$VM_DIR" ]]; then
    echo "VMディレクトリを作成中..."
    mkdir -p "$VM_DIR"
fi

if [[ ! -e "$DISK_FILE" ]]; then
	echo "仮想ディスクが見つかりません"
fi


KVM_OPTIONS=""
if [[ -e /dev/kvm && -r /dev/kvm ]]; then
    KVM_OPTIONS="-enable-kvm"
    echo "KVM加速を使用します"
else
    echo "警告: KVMが利用できません（エミュレーションモード）"
fi


CPU_OPTION="-cpu qemu64"
if [[ -n "$KVM_OPTIONS" ]]; then
    CPU_OPTION="-cpu host"
fi

echo "仮想マシンを起動中..."

qemu-system-x86_64 \
    -machine q35 \
    $KVM_OPTIONS \
    $CPU_OPTION \
    -smp 6 \
    -m 4G \
    -device ich9-intel-hda,id=sound0 \
    -device hda-duplex,bus=sound0.0 \
    -netdev user,id=net0 \
    -device virtio-net,netdev=net0 \
    -drive file="$DISK_FILE",format=qcow2,if=virtio \
    -boot d \
    -vga virtio \
    -display gtk,grab-on-hover=on \
    -global virtio-vga.xres=1920 \
    -global virtio-vga.yres=1080


