#!/bin/bash
# assemble.sh — Assemble a KIWI build directory from experience + base layers
# Usage: ./assemble.sh <base> [build-dir]
# Example: ./assemble.sh ubuntu /tmp/forge-build
set -euxo pipefail

BASE="${1:?Usage: $0 <base> [build-dir]}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
BUILD_DIR="${2:-$PROJECT_ROOT/_build/$BASE}"

BASE_DIR="$PROJECT_ROOT/bases/$BASE"
EXPERIENCE_DIR="$PROJECT_ROOT/experience"

[ -d "$BASE_DIR" ] || { echo "Error: base '$BASE' not found at $BASE_DIR"; exit 1; }
[ -f "$BASE_DIR/appliance.kiwi" ] || { echo "Error: $BASE_DIR/appliance.kiwi not found"; exit 1; }

echo "=== Assembling KIWI build dir for base: $BASE ==="
echo "    Base:       $BASE_DIR"
echo "    Experience: $EXPERIENCE_DIR"
echo "    Output:     $BUILD_DIR"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Copy base KIWI description
cp "$BASE_DIR/appliance.kiwi" "$BUILD_DIR/"
cp "$BASE_DIR/config.sh" "$BUILD_DIR/"
[ -f "$BASE_DIR/_constraints" ] && cp "$BASE_DIR/_constraints" "$BUILD_DIR/"

# Create root overlay by merging experience + base overlays
echo "=== Merging root overlay ==="
mkdir -p "$BUILD_DIR/root"
# Experience layer (GRUB, Plymouth, wallpapers, os-release, dconf, etc.)
cp -a "$EXPERIENCE_DIR/overlay/." "$BUILD_DIR/root/"
# Base-specific overlay on top (overrides experience if conflicts)
if [ -d "$BASE_DIR/root" ]; then
    cp -a "$BASE_DIR/root/." "$BUILD_DIR/root/"
fi

echo "=== Assembly complete: $BUILD_DIR ==="
ls -la "$BUILD_DIR/"
