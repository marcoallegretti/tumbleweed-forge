#!/bin/bash
# config.sh — Ubuntu Noble 24.04 base configuration
# Runs inside the image chroot during KIWI build.
set -euxo pipefail

#============================================
# 1. Purge Snap completely
#============================================
systemctl disable snapd.service snapd.socket snapd.seeded.service 2>/dev/null || true
apt-get purge -y snapd snap-confine 2>/dev/null || true
rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd
# Prevent snapd from being reinstalled
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
# Force password change on first login
chage -d 0 forge

#============================================
# 3. Enable services
#============================================
systemctl enable gdm3
systemctl enable NetworkManager
systemctl set-default graphical.target

#============================================
# 4. Locale and keyboard (Ubuntu method)
#============================================
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# Keyboard setup via console-setup (Ubuntu doesn't use systemd keymaps)
cat > /etc/default/keyboard <<KBEOF
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
KBEOF
dpkg-reconfigure -f noninteractive keyboard-configuration 2>/dev/null || true

#============================================
# 5. Apply openSUSE Experience Layer
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
