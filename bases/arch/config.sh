#!/bin/bash
set -ex

#======================================
# Enable NetworkManager
#--------------------------------------
systemctl enable NetworkManager

#======================================
# Enable SDDM display manager
#--------------------------------------
systemctl enable sddm

#======================================
# Enable DNS resolution
#--------------------------------------
systemctl enable systemd-resolved

#======================================
# Enable first mirror in mirrorlist
#--------------------------------------
sed -ie '0,/#Server/s/#Server/Server/' /etc/pacman.d/mirrorlist

#======================================
# Generate system locale
#--------------------------------------
sed -ie '0,/#en_US.UTF-8/s/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

#======================================
# Keyboard layout
#--------------------------------------
echo "KEYMAP=us" > /etc/vconsole.conf

#======================================
# Hostname
#--------------------------------------
echo "tumbleweed-forge" > /etc/hostname

#======================================
# Sudo for wheel group (Arch convention)
#--------------------------------------
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

#======================================
# Plasma wallpaper (Forge identity)
#--------------------------------------
SKEL_PLASMA="/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc"
mkdir -p "$(dirname "$SKEL_PLASMA")"
cat > "$SKEL_PLASMA" << 'PLASMAEOF'
[Containments][1]
wallpaperplugin=org.kde.image

[Containments][1][Wallpaper][org.kde.image][General]
Image=/usr/share/wallpapers/openSUSE-default.png
PLASMAEOF

#======================================
# SDDM Breeze theme
#--------------------------------------
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/theme.conf << 'SDDMEOF'
[Theme]
Current=breeze
SDDMEOF

#======================================
# Apply Forge boot identity
#--------------------------------------
if [ -f /opt/forge/apply-experience.sh ]; then
    source /opt/forge/apply-experience.sh
fi
