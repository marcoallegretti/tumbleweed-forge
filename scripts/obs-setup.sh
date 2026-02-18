#!/bin/bash
set -euxo pipefail

# Usage: ./obs-setup.sh YOUR_OBS_USERNAME
OBS_USER="${1:?Usage: $0 OBS_USERNAME}"
PROJECT="home:${OBS_USER}:TumbleweedForge"
PKG="tumbleweed-forge-image"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OBS_DIR="$PROJECT_ROOT/obs"

echo "=== Creating OBS project: $PROJECT ==="
osc meta prj "$PROJECT" -F "$OBS_DIR/project-meta.xml"

echo "=== Setting project config ==="
osc meta prjconf "$PROJECT" -F "$OBS_DIR/project-config.txt"

echo "=== Creating package: $PKG ==="
osc meta pkg "$PROJECT" "$PKG" -F - <<EOF
<package name="$PKG" project="$PROJECT">
  <title>Tumbleweed Forge Image</title>
  <description>KIWI-ng image for Tumbleweed Forge - Ubuntu Edition</description>
</package>
EOF

echo "=== Uploading _service and _constraints ==="
TMPDIR=$(mktemp -d)
osc checkout "$PROJECT" "$PKG" -o "$TMPDIR/$PKG"
cp "$OBS_DIR/_service" "$TMPDIR/$PKG/_service"
cp "$PROJECT_ROOT/kiwi/_constraints" "$TMPDIR/$PKG/_constraints"
pushd "$TMPDIR/$PKG"
osc add _service _constraints 2>/dev/null || true
osc commit -m "Initial setup: obs_scm integration"
popd
rm -rf "$TMPDIR"

echo "=== Done! Check: https://build.opensuse.org/project/show/$PROJECT ==="
