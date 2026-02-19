#!/bin/bash
# obs-setup.sh — Set up an OBS project for a Tumbleweed Forge base
# Usage: ./obs-setup.sh <base> <OBS_USERNAME>
# Example: ./obs-setup.sh ubuntu Mighty23
set -euxo pipefail

BASE="${1:?Usage: $0 <base> <OBS_USERNAME>}"
OBS_USER="${2:?Usage: $0 <base> <OBS_USERNAME>}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
OBS_DIR="$PROJECT_ROOT/ci/obs"
BASE_OBS_DIR="$OBS_DIR/$BASE"
BASE_DIR="$PROJECT_ROOT/bases/$BASE"

[ -f "$BASE_OBS_DIR/_service" ] || { echo "Error: _service not found at $BASE_OBS_DIR"; exit 1; }

# Derive project/package names from base
PROJECT="home:${OBS_USER}:TumbleweedForge"
PKG="tumbleweed-forge-${BASE}"

echo "=== Creating OBS project: $PROJECT ==="
osc meta prj "$PROJECT" -F "$OBS_DIR/project-meta.xml"

echo "=== Setting project config ==="
osc meta prjconf "$PROJECT" -F "$OBS_DIR/project-config.txt"

echo "=== Creating package: $PKG ==="
osc meta pkg "$PROJECT" "$PKG" -F - <<EOF
<package name="$PKG" project="$PROJECT">
  <title>Tumbleweed Forge - ${BASE^} Edition</title>
  <description>KIWI-ng image for Tumbleweed Forge - ${BASE^} Edition</description>
</package>
EOF

echo "=== Uploading _service and _constraints ==="
TMPDIR=$(mktemp -d)
osc checkout "$PROJECT" "$PKG" -o "$TMPDIR/$PKG"
cp "$BASE_OBS_DIR/_service" "$TMPDIR/$PKG/_service"
[ -f "$BASE_DIR/_constraints" ] && cp "$BASE_DIR/_constraints" "$TMPDIR/$PKG/_constraints"
pushd "$TMPDIR/$PKG"
osc add _service _constraints 2>/dev/null || true
osc commit -m "Initial setup: obs_scm integration for $BASE"
popd
rm -rf "$TMPDIR"

echo "=== Done! Check: https://build.opensuse.org/project/show/$PROJECT ==="
