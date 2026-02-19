#!/bin/bash
# apply-experience.sh — Distribution-agnostic openSUSE Experience Layer
# Sourced by each base's config.sh after base-specific setup.
# Expects: dconf-cli, plymouth, grub2 installed in the image.

set -euxo pipefail

#============================================
# 1. Enable Dash-to-Dock for all users
#============================================
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

#============================================
# 2. Rebuild dconf database
#============================================
dconf update

#============================================
# 3. Apply GRUB theme
#============================================
if [ -f /boot/grub/themes/openSUSE/theme.txt ]; then
    update-grub 2>/dev/null || true
elif [ -f /boot/grub2/themes/openSUSE/theme.txt ]; then
    # openSUSE/Fedora use grub2 path
    grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null || true
fi

#============================================
# 4. Set Plymouth theme
#============================================
plymouth-set-default-theme spinner 2>/dev/null || true
