#!/bin/bash
# apply-experience.sh — openSUSE Experience Layer configuration
# Sourced by each base's config.sh after base-specific setup.
#
# The base config.sh should export FORGE_DE before sourcing this script:
#   export FORGE_DE=gnome   (Ubuntu, Debian)
#   export FORGE_DE=dde     (Deepin)
#
# If FORGE_DE is unset, the script auto-detects from installed packages.

set -euxo pipefail

# Auto-detect DE if not specified
if [ -z "${FORGE_DE:-}" ]; then
    if command -v gnome-shell >/dev/null 2>&1; then
        FORGE_DE=gnome
    elif command -v startdde >/dev/null 2>&1; then
        FORGE_DE=dde
    else
        FORGE_DE=unknown
    fi
fi
echo "=== Applying openSUSE experience (DE: $FORGE_DE) ==="

#============================================
# 1. GRUB theme (all DEs)
#============================================
if [ -f /boot/grub/themes/openSUSE/theme.txt ]; then
    update-grub 2>/dev/null || true
elif [ -f /boot/grub2/themes/openSUSE/theme.txt ]; then
    grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true
fi

#============================================
# 2. Plymouth theme (all DEs)
#============================================
plymouth-set-default-theme spinner 2>/dev/null || true

#============================================
# 3. Wallpaper setup (all DEs)
#============================================
# Wallpapers are in /usr/share/wallpapers/ via the overlay.
# DE-specific wallpaper activation happens below.

#============================================
# 4. GNOME-specific configuration
#============================================
if [ "$FORGE_DE" = "gnome" ]; then
    # Enable Dash-to-Dock if installed
    if [ -d /usr/share/gnome-shell/extensions/ubuntu-dock@ubuntu.com ]; then
        EXTENSION_ID="ubuntu-dock@ubuntu.com"
    elif [ -d /usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com ]; then
        EXTENSION_ID="dash-to-dock@micxgx.gmail.com"
    else
        EXTENSION_ID=""
    fi

    if [ -n "$EXTENSION_ID" ]; then
        cat >> /etc/dconf/db/local.d/01-ubuntu-ergonomics.conf <<DOCKEOF

[org/gnome/shell]
enabled-extensions=['${EXTENSION_ID}']
DOCKEOF
    fi

    # Rebuild dconf database
    dconf update
fi

#============================================
# 5. DDE-specific configuration
#============================================
if [ "$FORGE_DE" = "dde" ]; then
    # Set openSUSE wallpaper as default for DDE
    if [ -f /usr/share/wallpapers/openSUSE-default.png ]; then
        mkdir -p /etc/deepin/dde-appearance
        cat > /etc/deepin/dde-appearance/override.json <<'DDEEOF'
{
    "wallpaper": "/usr/share/wallpapers/openSUSE-default.png"
}
DDEEOF
    fi

    # Enable lightdm if present
    if command -v lightdm >/dev/null 2>&1; then
        systemctl enable lightdm.service 2>/dev/null || true
    fi
fi

echo "=== Experience layer applied ==="
