# Tumbleweed Forge

A cross-distribution image framework with openSUSE visual identity, built by **OBS + KIWI-ng** — demonstrating the portability of the openSUSE build infrastructure.

```
┌─────────────┐    webhook     ┌──────────┐    auto-rebuild    ┌──────────────┐
│  GitHub Repo │ ────────────► │   OBS    │ ◄────────────────── │  Upstream    │
│  (this repo) │ push to main  │ scheduler│  pkg change         │  repos       │
└─────────────┘                └────┬─────┘                     └──────────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              ▼                     ▼                     ▼
     ┌────────────────┐  ┌────────────────┐  ┌────────────────┐
     │ Ubuntu Edition │  │ Debian Edition │  │   ... more     │
     │  (Noble 24.04) │  │ (Bookworm 12)  │  │                │
     └────────┬───────┘  └────────┬───────┘  └────────────────┘
              └─────────┬─────────┘
                        ▼
              ┌───────────────────────────┐
              │  download.opensuse.org    │
              │  (static link, GPG-signed)│
              └───────────────────────────┘
```

## What Is This?

Tumbleweed Forge demonstrates that openSUSE's infrastructure (OBS, KIWI-ng) can build and maintain **any** Linux distribution — not just RPM-based ones. The framework produces system images that:

- **Look like openSUSE GNOME** — real branding ported from `glib2-branding-openSUSE`
- **Feel familiar** — Dash-to-Dock, desktop ergonomics matching the base distribution
- **Run any base underneath** — Ubuntu, Debian, and more via modular base profiles
- **Build on OBS** — automatic rebuilds on upstream changes, GPG-signed, static download URLs

## Quick Start

### Local Build

Prerequisites: `kiwi-ng` installed, root/sudo access.

```bash
# Build Ubuntu edition
ci/scripts/build-local.sh ubuntu

# Build Debian edition
ci/scripts/build-local.sh debian
```

Test in QEMU:
```bash
ci/scripts/test-image.sh
```

### OBS Build

See [ci/obs/README-OBS-SETUP.md](ci/obs/README-OBS-SETUP.md) for the full setup guide, or:

```bash
ci/scripts/obs-setup.sh ubuntu Mighty23
```

## Architecture

Tumbleweed Forge uses a **three-layer model** — see [docs/architecture.md](docs/architecture.md) for details.

```
experience/                  openSUSE Experience Layer (distro-agnostic)
  overlay/                   Files overlaid onto every image
    boot/grub/themes/        GRUB openSUSE theme
    etc/dconf/               GNOME dconf overrides
    etc/os-release           Forge identity
    usr/share/wallpapers/    openSUSE wallpapers
    usr/share/plymouth/      Boot splash watermark
    opt/forge/               apply-experience.sh
  apply-experience.sh        Shared config script (dconf, GRUB, Plymouth)
  README.md                  Branding architecture
  upstream-sources.md        Asset provenance

bases/                       Base Layer (distro-specific)
  ubuntu/                    Ubuntu Noble 24.04 LTS
    appliance.kiwi           KIWI image description
    config.sh                Ubuntu-specific post-install
    root/                    Ubuntu-specific overlay (no-snap.pref)
    _constraints             OBS build resources
  debian/                    Debian Bookworm 12
    appliance.kiwi           KIWI image description
    config.sh                Debian-specific post-install
    _constraints             OBS build resources

ci/                          Build Layer
  obs/                       Per-base OBS configurations
    ubuntu/                  project-meta, project-config, _service
    debian/                  project-meta, project-config, _service
  scripts/                   Build automation
    assemble.sh              Merge experience + base into KIWI build dir
    build-local.sh           Local KIWI build with repo injection
    obs-setup.sh             OBS project creation
    test-image.sh            QEMU boot test

docs/                        Documentation
  architecture.md            Three-layer architecture
  governance.md              Branding & governance policy

.obs/workflows.yml           GitHub → OBS CI integration
```

## How the Rolling Update Works

Two automatic trigger paths — zero manual intervention:

1. **You push to git** → GitHub webhook → OBS pulls new sources via `obs_scm` → rebuilds image
2. **Upstream pushes a package update** → OBS scheduler detects dependency change → automatic rebuild

## Supported Bases

| Base | Status | Description |
|---|---|---|
| **Ubuntu Noble 24.04** | Building on OBS | Snap-free, full GNOME desktop |
| **Debian Bookworm 12** | In development | Stability reference |
| Fedora | Planned (Phase 2) | Innovation reference |
| Arch | Planned (Phase 2) | Advanced user segment |

## Tech Stack

| Component | Role |
|---|---|
| **OBS** | Central orchestrator — builds, signs, publishes, auto-rebuilds |
| **KIWI-ng** | Image builder — produces deployable `.raw` disk images |
| **GNOME** | Desktop environment with openSUSE branding |
| **Agama** | Installer (future phase) |

## License

GPL-2.0 — see [LICENSE](LICENSE).
