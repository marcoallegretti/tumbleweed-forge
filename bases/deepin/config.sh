#!/bin/bash
# config.sh — Deepin 23 (beige) base configuration
# Runs inside the image chroot during KIWI build.
#
# Philosophy: native DDE experience with Forge boot identity.
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
systemctl enable lightdm.service
systemctl enable NetworkManager
systemctl set-default graphical.target

#============================================
# 3. Locale and keyboard
#============================================
sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
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
# 4. DDE desktop configuration
#============================================
# Set Forge wallpaper as DDE default
if [ -f /usr/share/wallpapers/openSUSE-default.png ]; then
    mkdir -p /etc/deepin/dde-appearance
    cat > /etc/deepin/dde-appearance/override.json <<'DDEEOF'
{
    "wallpaper": "/usr/share/wallpapers/openSUSE-default.png"
}
DDEEOF
fi

#============================================
# 5. Apply Forge boot identity (GRUB + Plymouth)
#============================================
if [ -f /opt/forge/apply-experience.sh ]; then
    source /opt/forge/apply-experience.sh
fi

#============================================
# 6. Clean up
#============================================
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
