# Tumbleweed Forge — UX Conformance Matrix

This document defines the **native reference UX** for each supported base.
Every Forge edition must match its upstream distro's desktop experience as
closely as possible. The only Forge-specific additions are boot-level
identity (GRUB theme, Plymouth splash, os-release, wallpapers).

## Guiding Principle

> If a user installs the reference distro and then boots a Forge edition,
> the desktop session should feel identical. Only the boot sequence and
> system identity differ.

## Image Types

Each edition ships two image variants:

| Variant | KIWI type | Use case |
|---|---|---|
| **OEM disk** | `image="oem"` | Write to disk / VM, auto-resize on first boot |
| **Live ISO** | `image="iso"` | USB stick / test drive, no install required |

## Per-Distro Reference

### Ubuntu Noble 24.04

| Aspect | Reference | Forge edition |
|---|---|---|
| **Metapackage** | `ubuntu-desktop` | Packages matching `ubuntu-desktop` deps |
| **Desktop** | GNOME + Ubuntu Dock | GNOME + `gnome-shell-extension-ubuntu-dock` |
| **Display manager** | GDM3 | GDM3 |
| **Session** | Wayland (default), X11 fallback | Same |
| **Default apps** | Nautilus, Snap Store, Firefox (snap) | Nautilus, Firefox (deb); snap removed |
| **Branding** | Ubuntu wallpaper, Yaru theme | Yaru theme, Forge wallpaper overlay |
| **Init** | systemd | systemd |
| **Network** | NetworkManager | NetworkManager |
| **Update path** | `apt upgrade` | Same |
| **OBS status** | ✅ building | ✅ |

**Deviation note**: Snap is removed. Firefox is installed as a deb package.
This is a deliberate choice — Forge images are meant to be snap-free.

---

### Debian Bookworm 12

| Aspect | Reference | Forge edition |
|---|---|---|
| **Metapackage** | `task-gnome-desktop` | Packages matching `gnome` + `desktop-base` deps |
| **Desktop** | GNOME (vanilla upstream) | GNOME (vanilla upstream) |
| **Display manager** | GDM3 | GDM3 |
| **Session** | Wayland (default), X11 fallback | Same |
| **Default apps** | Evolution, Rhythmbox, Shotwell, Cheese, LibreOffice, Synaptic | Same set |
| **Branding** | `desktop-base` (Debian wallpapers, themes) | `desktop-base` + Forge boot identity |
| **Init** | systemd | systemd |
| **Network** | NetworkManager + `network-manager-gnome` | Same |
| **Update path** | `apt upgrade` | Same |
| **OBS status** | ✅ building | ✅ |

**Key difference from Ubuntu**: Debian GNOME is vanilla upstream GNOME with
no extensions or dock. The `desktop-base` package provides Debian-specific
wallpapers and Plymouth themes. A full install includes LibreOffice and
media apps via the `gnome` metapackage (not just `gnome-core`).

---

### Deepin 23 (beige)

| Aspect | Reference | Forge edition |
|---|---|---|
| **Metapackage** | `deepin-desktop-environment` | Packages matching DDE deps |
| **Desktop** | DDE (Deepin Desktop Environment) | DDE |
| **Display manager** | LightDM + deepin-greeter | LightDM + deepin-greeter |
| **Session** | X11 (DDE default) | Same |
| **Default apps** | Deepin File Manager, Terminal, Editor, etc. | Same set |
| **Branding** | Deepin wallpapers, dock, launcher | Deepin native + Forge boot identity |
| **Init** | systemd | systemd |
| **Network** | NetworkManager + DDE network plugin | Same |
| **Update path** | `apt upgrade` | Same |
| **OBS status** | 🔧 local only | External repo not mirrored on OBS |

---

### KDE Neon (Ubuntu 24.04 + Plasma 6)

| Aspect | Reference | Forge edition |
|---|---|---|
| **Metapackage** | `neon-desktop` | Packages matching `neon-desktop` deps |
| **Desktop** | KDE Plasma 6 | Plasma 6 |
| **Display manager** | SDDM + Breeze theme | SDDM + `sddm-theme-breeze` |
| **Session** | Wayland (default), X11 fallback | Same |
| **Default apps** | Dolphin, Konsole, Kate, Gwenview, Okular, Discover | Same set |
| **Branding** | Breeze theme, KDE wallpapers | Breeze theme + Forge wallpaper overlay |
| **Init** | systemd | systemd |
| **Network** | NetworkManager + `plasma-nm` | Same |
| **Update path** | `apt full-upgrade` (rolling KDE) | Same |
| **OBS status** | 🔧 local only | External repo not mirrored on OBS |

---

### Arch Linux (planned)

| Aspect | Reference | Forge edition |
|---|---|---|
| **Package manager** | pacman | pacman |
| **Desktop** | None by default (user choice) | KDE Plasma (most popular Arch DE) |
| **Display manager** | None by default | SDDM |
| **Session** | User choice | Wayland (Plasma default) |
| **Default apps** | None by default | Minimal: Dolphin, Konsole, Kate, Firefox |
| **Branding** | None (Arch is unbranded) | Forge boot identity only |
| **Init** | systemd | systemd |
| **Network** | systemd-networkd or NetworkManager | NetworkManager + `plasma-nm` |
| **Update path** | `pacman -Syu` (rolling) | Same |
| **OBS status** | ✅ repos available | `Arch:Core`, `Arch:Extra`, `Arch:Community` |

**Arch UX philosophy**: Arch does not ship a desktop. The "Arch experience"
is a minimal, user-configured system. For Forge, we ship KDE Plasma as the
default DE (most popular choice in the Arch community per surveys), but keep
the package set minimal — no bloat, no LibreOffice, no unnecessary services.
The user retains full pacman control post-install.

**Key differences from DEB-based editions**:
- pacman instead of apt
- Rolling release for everything (not just DE)
- No metapackages — explicit package lists
- KIWI uses `pacman` bootstrap, not `apt`

## Forge-Only Additions (applied to all editions)

These are the **only** items that differ from the upstream distro:

| Item | What it does |
|---|---|
| GRUB theme | openSUSE-branded boot menu |
| Plymouth splash | Forge logo during boot |
| `/etc/os-release` | Identifies image as Tumbleweed Forge |
| `/etc/issue` | Login banner |
| Wallpapers | openSUSE wallpapers available (not forced as default) |

Desktop defaults (theme, icons, dock, panel, apps) come from the distro,
not from Forge.
