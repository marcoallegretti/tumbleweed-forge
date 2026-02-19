#!/bin/bash
# apply-experience.sh — Tumbleweed Forge boot identity
# Sourced by each base's config.sh after base-specific setup.
#
# This script handles ONLY universal boot-level branding:
#   - GRUB theme activation
#   - Plymouth theme activation
#
# Desktop-specific configuration (GNOME dconf, DDE settings,
# display managers, wallpaper activation) belongs in each
# base's own config.sh — not here.

set -euxo pipefail

echo "=== Applying Forge boot identity ==="

#============================================
# 1. GRUB theme
#============================================
if [ -f /boot/grub/themes/openSUSE/theme.txt ]; then
    update-grub 2>/dev/null || true
elif [ -f /boot/grub2/themes/openSUSE/theme.txt ]; then
    grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true
fi

#============================================
# 2. Plymouth theme
#============================================
plymouth-set-default-theme spinner 2>/dev/null || true

echo "=== Forge boot identity applied ==="
