#!/bin/bash
# build-local.sh — Build a Tumbleweed Forge image locally
# Usage: ./build-local.sh <base> [--profile disk|live] [output-dir]
# Example: ./build-local.sh ubuntu
#          ./build-local.sh debian --profile live /tmp/forge-output
set -euxo pipefail

BASE="${1:?Usage: $0 <base> [--profile disk|live] [output-dir]}"
shift

PROFILE="disk"
if [ "${1:-}" = "--profile" ]; then
    PROFILE="${2:?--profile requires a value (disk or live)}"
    shift 2
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TARGET_DIR="${1:-$PROJECT_ROOT/build-output}"

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
    kde-neon)
        REPOS=(
            "--add-repo" "http://archive.neon.kde.org/user,apt-deb,noble,main,neon-user,false"
            "--add-repo" "http://archive.ubuntu.com/ubuntu,apt-deb,noble,main restricted universe multiverse,noble,false"
            "--add-repo" "http://archive.ubuntu.com/ubuntu,apt-deb,noble-updates,main restricted universe multiverse,noble-updates,false"
            "--add-repo" "http://security.ubuntu.com/ubuntu,apt-deb,noble-security,main restricted universe multiverse,noble-security,false"
            "--add-repo" "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/xUbuntu_24.04,apt-deb,kiwi-builder,,xUbuntu_24.04,false"
        )
        ;;
    arch)
        REPOS=(
            "--add-repo" "https://geo.mirror.pkgbuild.com/core/os/x86_64,pacman,Arch_Core_standard,core,,false"
            "--add-repo" "https://geo.mirror.pkgbuild.com/extra/os/x86_64,pacman,Arch_Extra_standard,extra,,false"
            "--add-repo" "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Staging/Arch_Linux,pacman,Virtualization_Appliances_Staging_Arch_Linux,kiwi-staging,,false"
            "--add-repo" "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Images:/Testing_x86:/archlinux/standard,pacman,Virtualization_Appliances_Images_Testing_x86_archlinux_standard,dracut-hooks,,false"
        )
        ;;
    *)
        echo "Error: unknown base '$BASE'. Available: ubuntu, debian, deepin, kde-neon, arch"
        exit 1
        ;;
esac

# Step 3: Run KIWI build
sudo kiwi-ng --profile "$PROFILE" system build \
    --description "$BUILD_DIR" \
    --target-dir "$TARGET_DIR" \
    "${REPOS[@]}"

echo "Build complete ($PROFILE profile). Output: $TARGET_DIR/"
