#!/bin/bash
# config.sh — Debian Bookworm 12 base configuration
# Runs inside the image chroot during KIWI build.
#
# Philosophy: vanilla Debian GNOME experience.
# Only Forge identity is applied (wallpaper, GDM logo).
# No GNOME behavior overrides — Debian's defaults are preserved.
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
# 3. Locale and keyboard (Debian method)
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
# 4. GNOME identity (wallpaper + GDM logo only)
#============================================
# Create dconf identity if not present (OBS builds lack base overlay)
if [ ! -f /etc/dconf/db/local.d/00-forge-identity.conf ]; then
    mkdir -p /etc/dconf/db/local.d /etc/dconf/profile
    cat > /etc/dconf/db/local.d/00-forge-identity.conf <<'DCONF_ID'
# Tumbleweed Forge identity — wallpaper only
# No behavior overrides: vanilla Debian GNOME experience preserved.

[org/gnome/desktop/background]
picture-uri='file:///usr/share/wallpapers/openSUSE-default.png'
picture-uri-dark='file:///usr/share/wallpapers/openSUSE-default-dark.png'
picture-options='zoom'

[org/gnome/desktop/screensaver]
picture-uri='file:///usr/share/wallpapers/openSUSE-default.png'
picture-options='zoom'

[org/gnome/login-screen]
logo='/usr/share/gdm/greeter/images/distributor.svg'
DCONF_ID
    cat > /etc/dconf/profile/user <<'DCONF_PROF'
user-db:user
system-db:local
DCONF_PROF
fi

dconf update

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
