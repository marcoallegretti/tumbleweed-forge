#!/bin/bash
# config.sh — Ubuntu Noble 24.04 native UX configuration
# Runs inside the image chroot during KIWI build.
set -euxo pipefail

#============================================
# 1. Set up default user
#============================================
mkdir -p /home/forge
chown forge:forge /home/forge
chmod 750 /home/forge
chage -d 0 forge

#============================================
# 2. Enable services
#============================================
systemctl enable gdm3
systemctl enable NetworkManager
systemctl set-default graphical.target

#============================================
# 3. Locale and keyboard
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

#============================================
# 4. Clean up
#============================================
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
