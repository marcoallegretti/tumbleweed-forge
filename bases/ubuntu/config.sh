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
chage -d 0 forge

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

cat > /etc/default/keyboard <<KBEOF
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
KBEOF
dpkg-reconfigure -f noninteractive keyboard-configuration 2>/dev/null || true

cat > /etc/os-release <<'OSREL'
PRETTY_NAME="Tumbleweed Forge - Ubuntu Edition"
NAME="Tumbleweed Forge"
VERSION_ID="24.04"
VERSION="24.04 LTS (Noble Numbat) [Forge]"
VERSION_CODENAME=noble
ID=tumbleweed-forge
ID_LIKE="ubuntu debian"
HOME_URL="https://github.com/marcoallegretti/tumbleweed-forge"
SUPPORT_URL="https://github.com/marcoallegretti/tumbleweed-forge/issues"
BUG_REPORT_URL="https://github.com/marcoallegretti/tumbleweed-forge/issues"
UBUNTU_CODENAME=noble
OSREL

cat > /etc/issue <<'ISSUE'
Tumbleweed Forge - Ubuntu Edition \n \l

ISSUE

cat > /etc/issue.net <<'ISSUENET'
Tumbleweed Forge - Ubuntu Edition
ISSUENET

#============================================
# 5. GNOME desktop configuration (Ubuntu-native)
#============================================
# Create dconf identity if not present (OBS builds lack base overlay)
if [ ! -f /etc/dconf/db/local.d/00-opensuse-branding.conf ]; then
    mkdir -p /etc/dconf/db/local.d /etc/dconf/profile
    cat > /etc/dconf/db/local.d/00-opensuse-branding.conf <<'DCONF_ID'
# Tumbleweed Forge identity for Ubuntu edition
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

# Dash-to-Dock ergonomics if not present from overlay
if [ ! -f /etc/dconf/db/local.d/01-ubuntu-ergonomics.conf ]; then
    cat > /etc/dconf/db/local.d/01-ubuntu-ergonomics.conf <<'DOCK_CONF'
# Ubuntu-style ergonomics: Dash-to-Dock on left
[org/gnome/shell/extensions/dash-to-dock]
dock-position='LEFT'
dash-max-icon-size=40
background-opacity=0.7
transparency-mode='FIXED'
custom-theme-shrink=true
running-indicator-style='DOTS'
DOCK_CONF
fi

# Enable Dash-to-Dock extension if installed
if [ -d /usr/share/gnome-shell/extensions/ubuntu-dock@ubuntu.com ]; then
    DOCK_ID="ubuntu-dock@ubuntu.com"
elif [ -d /usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com ]; then
    DOCK_ID="dash-to-dock@micxgx.gmail.com"
else
    DOCK_ID=""
fi

if [ -n "$DOCK_ID" ]; then
    cat >> /etc/dconf/db/local.d/01-ubuntu-ergonomics.conf <<DOCKEOF

[org/gnome/shell]
enabled-extensions=['${DOCK_ID}']
DOCKEOF
fi

# Rebuild dconf database
dconf update

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
