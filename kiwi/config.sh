#!/bin/bash
set -euxo pipefail

#============================================
# 1. Purge Snap completely
#============================================
systemctl disable snapd.service snapd.socket snapd.seeded.service 2>/dev/null || true
apt-get purge -y snapd snap-confine 2>/dev/null || true
rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd

#============================================
# 2. Rebuild dconf database
#============================================
dconf update

#============================================
# 3. Enable services
#============================================
systemctl enable gdm3
systemctl enable NetworkManager
systemctl set-default graphical.target

#============================================
# 4. Locale and keyboard
#============================================
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

#============================================
# 5. Clean up
#============================================
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
