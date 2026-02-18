# Branding Architecture

Tumbleweed Forge uses **real openSUSE GNOME branding** ported from upstream packages, combined with **Ubuntu-style desktop ergonomics** (Dash-to-Dock on left).

## Two-Layer Approach

### Layer 0: openSUSE GNOME Identity (`00-opensuse-branding.conf`)

Ported from `glib2-branding-openSUSE` (`GNOME:Factory/glib2-branding` on OBS). This sets:
- Wallpaper (official Tumbleweed day/night wallpapers)
- Background colors (`#63bbb2ff` / `#0c2a27ff`)
- Sound theme (`freedesktop`)
- Touchpad tap-to-click enabled
- Media key bindings
- Default favorite apps in the dash
- GDM login logo
- Tracker indexing settings

The theme, icon-theme, and fonts follow upstream GNOME defaults (Adwaita), which is what openSUSE ships.

### Layer 1: Ubuntu Ergonomics (`01-ubuntu-ergonomics.conf`)

This is the **only** layer we add beyond what openSUSE ships:
- Dash-to-Dock extension enabled
- Dock positioned on the left
- Transparent dock with 40px icons

This preserves the Ubuntu desktop workflow familiar to Ubuntu users.

## Branding Swap (Legal Compliance)

Per the white paper (Section 7A), upstream Ubuntu branding is removed:
- `ubuntu-wallpapers`, `yaru-theme-*` packages are deleted in `appliance.kiwi`
- `snapd` is purged in `config.sh`
- `/etc/os-release` identifies the system as "Tumbleweed Forge - Ubuntu Edition"
- `/etc/issue` shows the Forge identity at login

## Porting Process

The gschema override from openSUSE uses RPM macros (`@@IF_openSUSE@@`, `@@WALLPAPER_URI@@`). These are resolved manually:
- `@@IF_openSUSE@@` lines are kept (we are openSUSE-branded)
- `@@IF_SLE@@` and `@@IF_LEAP@@` lines are removed
- `@@WALLPAPER_URI@@` is resolved to `/usr/share/wallpapers/openSUSE-default.png`
- `@@WALLPAPER_URI_DARK@@` is resolved to `/usr/share/wallpapers/openSUSE-default-dark.png`

The result is placed in `kiwi/root/etc/dconf/db/local.d/00-opensuse-branding.conf` as a dconf local database override (the Ubuntu equivalent of a gschema override).
