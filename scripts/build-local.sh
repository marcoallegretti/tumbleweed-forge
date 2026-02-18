#!/bin/bash
set -euxo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KIWI_DIR="$PROJECT_ROOT/kiwi"
TARGET_DIR="$PROJECT_ROOT/build-output"

mkdir -p "$TARGET_DIR"

sudo kiwi-ng --profile=Local system build \
    --description "$KIWI_DIR" \
    --target-dir "$TARGET_DIR"

echo "Build complete. Output: $TARGET_DIR/"
