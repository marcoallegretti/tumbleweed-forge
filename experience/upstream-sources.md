# Upstream Branding Sources

Exact locations of the openSUSE branding assets used in Tumbleweed Forge.

## glib2-branding-openSUSE (GNOME dconf defaults)

- **OBS package**: `GNOME:Factory/glib2-branding`
- **Key file**: `glib2-branding.gschema.override.in`
- **OBS URL**: https://build.opensuse.org/package/show/GNOME:Factory/glib2-branding
- **Raw file**: https://api.opensuse.org/public/source/GNOME:Factory/glib2-branding/glib2-branding.gschema.override.in
- **What it sets**: wallpaper, background colors, sound theme, touchpad, media keys, favorite apps, GDM logo, etc.

## wallpaper-branding-openSUSE (Default wallpapers)

- **OBS package**: `Base:System/branding-openSUSE`
- **GitHub repo**: https://github.com/openSUSE/branding (release-specific branches)
- **Common path**: `/usr/share/wallpapers/openSUSE-default.png`
- **Reference**: https://news.opensuse.org/2024/04/09/common-wallpaper-path/

## wallpapers-openSUSE-extra (Community wallpapers)

- **OBS package**: `X11:common:Factory/wallpapers-openSUSE-extra`
- **GitHub repo**: https://github.com/openSUSE/wallpapers
- **Note**: SVGs rendered to PNGs at build time

## gdm-branding-openSUSE (GDM login screen)

- **OBS package**: `GNOME:Factory/gdm-branding` (or similar)
- **Software page**: https://software.opensuse.org/package/gdm-branding-openSUSE
- **What it sets**: GDM configuration defaults for openSUSE

## plymouth-branding-openSUSE (Boot splash)

- **Future**: Not yet ported. Will be added in a later phase.

## branding-openSUSE (Master branding package)

- **OBS package**: `Base:System/branding-openSUSE`
- **GitHub repo**: https://github.com/openSUSE/branding
- **Description**: Contains `/etc/SuSE-brand` and triggers installation of correct vendor branding packages.
