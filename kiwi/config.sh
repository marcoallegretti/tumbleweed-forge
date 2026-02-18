#!/bin/bash
set -euxo pipefail

#============================================
# 1. Purge Snap completely
#============================================
systemctl disable snapd.service snapd.socket snapd.seeded.service 2>/dev/null || true
apt-get purge -y snapd snap-confine 2>/dev/null || true
rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd

#============================================
# 2. Set up default user
#============================================
mkdir -p /home/forge
chown forge:forge /home/forge
chmod 750 /home/forge
# Force password change on first login
chage -d 0 forge

#============================================
# 3. Enable Dash-to-Dock for all users
#============================================
# Ubuntu's extension is "ubuntu-dock@ubuntu.com"
if [ -d /usr/share/gnome-shell/extensions/ubuntu-dock@ubuntu.com ]; then
    EXTENSION_ID="ubuntu-dock@ubuntu.com"
else
    EXTENSION_ID="dash-to-dock@micxgx.gmail.com"
fi

# Add extension to enabled list in dconf
cat >> /etc/dconf/db/local.d/01-ubuntu-ergonomics.conf <<EOF

[org/gnome/shell]
enabled-extensions=['${EXTENSION_ID}']
EOF

#============================================
# 4. Rebuild dconf database
#============================================
dconf update

#============================================
# 5. Enable services
#============================================
systemctl enable gdm3
systemctl enable NetworkManager
systemctl set-default graphical.target

#============================================
# 6. Locale and keyboard
#============================================
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

#============================================
# 7. Clean up
#============================================
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
