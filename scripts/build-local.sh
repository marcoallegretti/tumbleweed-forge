#!/bin/bash
set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KIWI_DIR="$PROJECT_ROOT/kiwi"
TARGET_DIR="${1:-$PROJECT_ROOT/build-output}"

mkdir -p "$TARGET_DIR"

# Repos are passed via --add-repo because OBS scheduler rejects
# non-obs:// URLs inside the .kiwi file.
sudo kiwi-ng system build \
    --description "$KIWI_DIR" \
    --target-dir "$TARGET_DIR" \
    --add-repo http://archive.ubuntu.com/ubuntu,apt-deb,noble,"main restricted universe multiverse",noble,false \
    --add-repo http://archive.ubuntu.com/ubuntu,apt-deb,noble-updates,"main restricted universe multiverse",noble-updates,false \
    --add-repo http://security.ubuntu.com/ubuntu,apt-deb,noble-security,"main restricted universe multiverse",noble-security,false \
    --add-repo https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/xUbuntu_24.04,apt-deb,kiwi-builder,,xUbuntu_24.04,false

echo "Build complete. Output: $TARGET_DIR/"
