#!/bin/bash
# test-image.sh — Boot a Tumbleweed Forge image in QEMU
# Usage: ./test-image.sh [image-path-or-build-output-dir]
set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

INPUT="${1:-$PROJECT_ROOT/build-output}"

if [ -f "$INPUT" ]; then
    IMAGE="$INPUT"
else
    IMAGE="$(find "$INPUT" -name '*.raw' | head -1)"
fi

[ -z "$IMAGE" ] && { echo "No .raw image found in $INPUT"; exit 1; }

echo "Booting image: $IMAGE"

qemu-system-x86_64 \
    -enable-kvm -m 4096 -smp 2 \
    -bios /usr/share/ovmf/OVMF.fd \
    -drive file="$IMAGE",format=raw,if=virtio \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0
