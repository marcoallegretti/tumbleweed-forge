#!/bin/bash
# build-local.sh — Build a Tumbleweed Forge image locally
# Usage: ./build-local.sh <base> [output-dir]
# Example: ./build-local.sh ubuntu /tmp/forge-output
set -euxo pipefail

BASE="${1:?Usage: $0 <base> [output-dir]}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TARGET_DIR="${2:-$PROJECT_ROOT/build-output}"

# Step 1: Assemble the KIWI build directory
"$SCRIPT_DIR/assemble.sh" "$BASE" "$PROJECT_ROOT/_build/$BASE"
BUILD_DIR="$PROJECT_ROOT/_build/$BASE"

mkdir -p "$TARGET_DIR"

# Step 2: Determine repos based on the base
case "$BASE" in
    ubuntu)
        REPOS=(
            "--add-repo" "http://archive.ubuntu.com/ubuntu,apt-deb,noble,main restricted universe multiverse,noble,false"
            "--add-repo" "http://archive.ubuntu.com/ubuntu,apt-deb,noble-updates,main restricted universe multiverse,noble-updates,false"
            "--add-repo" "http://security.ubuntu.com/ubuntu,apt-deb,noble-security,main restricted universe multiverse,noble-security,false"
            "--add-repo" "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/xUbuntu_24.04,apt-deb,kiwi-builder,,xUbuntu_24.04,false"
        )
        ;;
    debian)
        REPOS=(
            "--add-repo" "http://deb.debian.org/debian,apt-deb,bookworm,main contrib non-free non-free-firmware,bookworm,false"
            "--add-repo" "http://deb.debian.org/debian,apt-deb,bookworm-updates,main contrib non-free non-free-firmware,bookworm-updates,false"
            "--add-repo" "http://security.debian.org/debian-security,apt-deb,bookworm-security,main contrib non-free non-free-firmware,bookworm-security,false"
            "--add-repo" "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/Debian_12,apt-deb,kiwi-builder,,Debian_12,false"
        )
        ;;
    deepin)
        REPOS=(
            "--add-repo" "https://community-packages.deepin.com/beige,apt-deb,beige,main community,beige,false"
            "--add-repo" "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/Debian_12,apt-deb,kiwi-builder,,Debian_12,false"
        )
        ;;
    *)
        echo "Error: unknown base '$BASE'. Available: ubuntu, debian, deepin"
        exit 1
        ;;
esac

# Step 3: Run KIWI build
sudo kiwi-ng system build \
    --description "$BUILD_DIR" \
    --target-dir "$TARGET_DIR" \
    "${REPOS[@]}"

echo "Build complete. Output: $TARGET_DIR/"
