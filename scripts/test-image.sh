#!/bin/bash
set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

IMAGE="$(find "$PROJECT_ROOT/build-output" -name '*.raw' | head -1)"
[ -z "$IMAGE" ] && { echo "No .raw image found in build-output/"; exit 1; }

echo "Booting image: $IMAGE"

qemu-system-x86_64 \
    -enable-kvm -m 4096 -smp 2 \
    -bios /usr/share/ovmf/OVMF.fd \
    -drive file="$IMAGE",format=raw,if=virtio \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0
