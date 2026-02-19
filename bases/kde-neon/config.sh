#!/bin/bash
# config.sh — KDE Neon base configuration
# Runs inside the image chroot during KIWI build.
#
# Philosophy: native KDE Plasma experience with Forge boot identity.
# KDE Neon ships latest Plasma on Ubuntu LTS. SDDM, not GDM.
# No GNOME, no dconf — pure KDE/Qt stack.
set -euxo pipefail

#============================================
# 1. Purge Snap completely
#============================================
systemctl disable snapd.service snapd.socket snapd.seeded.service 2>/dev/null || true
apt-get purge -y snapd snap-confine 2>/dev/null || true
rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd
mkdir -p /etc/apt/preferences.d
cat > /etc/apt/preferences.d/no-snap.pref <<'SNAPEOF'
Package: snapd
Pin: release a=*
Pin-Priority: -10
SNAPEOF

#============================================
# 2. Set up default user
#============================================
mkdir -p /home/forge
chown forge:forge /home/forge
chmod 750 /home/forge
chage -d 0 forge

#============================================
# 3. Enable services
#============================================
systemctl enable sddm
systemctl enable NetworkManager
systemctl set-default graphical.target

#============================================
# 4. Locale and keyboard
#============================================
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

cat > /etc/default/keyboard <<KBEOF
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
KBEOF
dpkg-reconfigure -f noninteractive keyboard-configuration 2>/dev/null || true

cat > /etc/os-release <<'OSREL'
PRETTY_NAME="Tumbleweed Forge - KDE Neon Edition"
NAME="Tumbleweed Forge"
VERSION_ID="24.04"
VERSION="24.04 (Neon) [Forge]"
VERSION_CODENAME=noble
ID=tumbleweed-forge
ID_LIKE="ubuntu debian"
HOME_URL="https://github.com/marcoallegretti/tumbleweed-forge"
SUPPORT_URL="https://github.com/marcoallegretti/tumbleweed-forge/issues"
BUG_REPORT_URL="https://github.com/marcoallegretti/tumbleweed-forge/issues"
UBUNTU_CODENAME=noble
OSREL

cat > /etc/issue <<'ISSUE'
Tumbleweed Forge - KDE Neon Edition \n \l

ISSUE

cat > /etc/issue.net <<'ISSUENET'
Tumbleweed Forge - KDE Neon Edition
ISSUENET

#============================================
# 5. KDE Plasma configuration
#============================================
# Set Forge wallpaper as default for new users via /etc/skel
SKEL_PLASMA="/etc/skel/.config"
mkdir -p "$SKEL_PLASMA"

# Plasma desktop wallpaper configuration
cat > "$SKEL_PLASMA/plasma-org.kde.plasma.desktop-appletsrc" <<'PLASMAEOF'
[Containments][1]
activityId=
formfactor=0
immutability=1
lastScreen=0
location=0
plugin=org.kde.plasma.folder
wallpaperplugin=org.kde.image

[Containments][1][Wallpaper][org.kde.image][General]
Image=file:///usr/share/wallpapers/openSUSE-default.png
FillMode=1
PLASMAEOF

# SDDM configuration — use Breeze theme
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/forge.conf <<'SDDMEOF'
[Theme]
Current=breeze
SDDMEOF

#============================================
# 6. Apply Forge boot identity (GRUB + Plymouth)
#============================================
if [ -f /opt/forge/apply-experience.sh ]; then
    source /opt/forge/apply-experience.sh
fi

#============================================
# 7. Clean up
#============================================
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
