#!/bin/bash


VM_DIR="./vm"
DISK_FILE="$VM_DIR/vm-disk.qcow2"
ISO_FILE="ramine-amd64.hybrid.iso"


if [[ ! -d "$VM_DIR" ]]; then
    echo "VMディレクトリを作成中..."
    mkdir -p "$VM_DIR"
fi

if [[ ! -e "$DISK_FILE" ]]; then
    echo "仮想ディスクを作成中..."
    qemu-img create -f qcow2 "$DISK_FILE" 20G
    if [[ $? -ne 0 ]]; then
        echo "エラー: ディスク作成に失敗しました"
        exit 1
    fi
fi


if [[ ! -e "$ISO_FILE" ]]; then
    echo "警告: ISOファイル '$ISO_FILE' が見つかりません"
    echo "続行しますか？ (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
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
    -cdrom "$ISO_FILE" \
    -boot d \
    -vga virtio \
    -display gtk,grab-on-hover=on \
    -global virtio-vga.xres=1920 \
    -global virtio-vga.yres=1080


