#!/bin/bash
# test-image.sh — Boot-test a Tumbleweed Forge image in QEMU
#
# Usage:
#   ./test-image.sh <image-path>              # headless smoke test
#   ./test-image.sh <image-path> --interactive # graphical window
#
# Exit codes:
#   0 — boot succeeded (login prompt detected)
#   1 — boot failed or timed out
set -euo pipefail

IMAGE="${1:?Usage: $0 <image-path> [--interactive]}"
MODE="${2:-}"
TIMEOUT="${BOOT_TIMEOUT:-300}"

[ -f "$IMAGE" ] || { echo "Error: image not found: $IMAGE"; exit 1; }

# Detect KVM support
ACCEL="-accel tcg"
if [ -w /dev/kvm ]; then
    ACCEL="-accel kvm"
fi

# Locate OVMF firmware
OVMF=""
for path in /usr/share/OVMF/OVMF_CODE.fd \
            /usr/share/ovmf/OVMF.fd \
            /usr/share/edk2/ovmf/OVMF_CODE.fd; do
    [ -f "$path" ] && OVMF="$path" && break
done
[ -z "$OVMF" ] && { echo "Error: OVMF firmware not found"; exit 1; }

if [ "$MODE" = "--interactive" ]; then
    echo "Booting interactively: $IMAGE"
    exec qemu-system-x86_64 \
        $ACCEL -m 4096 -smp 2 \
        -bios "$OVMF" \
        -drive file="$IMAGE",format=raw,if=virtio \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0
fi

# Headless smoke test
SERIAL_LOG=$(mktemp /tmp/forge-boot-XXXXXX.log)
trap 'rm -f "$SERIAL_LOG"' EXIT

echo "=== Smoke test: $IMAGE ==="
echo "    Timeout: ${TIMEOUT}s"
echo "    Accel:   $ACCEL"
echo "    Log:     $SERIAL_LOG"

qemu-system-x86_64 \
    $ACCEL -m 4096 -smp 2 -nographic \
    -bios "$OVMF" \
    -drive file="$IMAGE",format=raw,if=virtio \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0 \
    -serial stdio \
    -monitor none \
    > "$SERIAL_LOG" 2>&1 &

QEMU_PID=$!
trap 'kill $QEMU_PID 2>/dev/null; rm -f "$SERIAL_LOG"' EXIT

ELAPSED=0
INTERVAL=5
while [ $ELAPSED -lt "$TIMEOUT" ]; do
    if ! kill -0 $QEMU_PID 2>/dev/null; then
        echo "FAIL: QEMU exited unexpectedly"
        cat "$SERIAL_LOG"
        exit 1
    fi

    if grep -qiE '(login:|Login incorrect|Welcome to)' "$SERIAL_LOG" 2>/dev/null; then
        echo "PASS: Boot completed in ${ELAPSED}s"
        kill $QEMU_PID 2>/dev/null || true
        exit 0
    fi

    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

echo "FAIL: Boot timed out after ${TIMEOUT}s"
echo "=== Last 40 lines of serial log ==="
tail -40 "$SERIAL_LOG"
kill $QEMU_PID 2>/dev/null || true
exit 1
