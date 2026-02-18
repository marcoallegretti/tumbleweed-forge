# Tumbleweed Forge — Ubuntu Edition

A rolling Ubuntu-based system image with openSUSE visual identity, built by **OBS + KIWI-ng** — engineered to showcase the power of the openSUSE build infrastructure.

```
┌─────────────┐     webhook      ┌─────────────┐     auto-rebuild     ┌──────────────┐
│  GitHub Repo │ ──────────────► │     OBS      │ ◄─────────────────── │ Ubuntu Noble  │
│  (this repo) │  push to main   │  (scheduler) │  upstream pkg change │   repos       │
└─────────────┘                  └──────┬───────┘                      └──────────────┘
                                        │
                                        ▼
                                ┌───────────────┐
                                │   KIWI-ng     │
                                │  (build VM)   │
                                └───────┬───────┘
                                        │
                                        ▼
                                ┌───────────────────────────┐
                                │  download.opensuse.org    │
                                │  (static link, GPG-signed)│
                                └───────────────────────────┘
```

## What Is This?

Tumbleweed Forge demonstrates that openSUSE's infrastructure (OBS, KIWI-ng) can build and maintain **any** Linux distribution — not just RPM-based ones. The proof of concept is an Ubuntu Noble 24.04 LTS system image that:

- **Looks like openSUSE GNOME** — real branding ported from `glib2-branding-openSUSE`
- **Feels like Ubuntu** — Dash-to-Dock on the left, familiar desktop ergonomics
- **Runs Ubuntu underneath** — full binary compatibility, apt package manager
- **Builds on OBS** — automatic rebuilds on upstream changes, GPG-signed, static download URLs
- **Is Snap-free** — clean GNOME experience without Canonical's Snap ecosystem

## Quick Start

### Local Build (Development)

Prerequisites: `kiwi-ng` installed, root/sudo access.

```bash
./scripts/build-local.sh
```

Test in QEMU:
```bash
./scripts/test-image.sh
```

### OBS Build (Production)

See [obs/README-OBS-SETUP.md](obs/README-OBS-SETUP.md) for the full setup guide, or use the automated script:

```bash
./scripts/obs-setup.sh Mighty23
```

## Project Structure

```
kiwi/                    KIWI-ng image description
  appliance.kiwi         Image config (profiles: Local + OBS)
  config.sh              Post-install customization
  root/                  Overlay tree (files copied into image)
  _constraints           OBS build resource requirements

obs/                     OBS project configuration
  project-meta.xml       Project metadata (repos, rebuild policy)
  project-config.txt     Build config (Prefer:, Repotype:)
  _service               obs_scm source service definition
  README-OBS-SETUP.md    Step-by-step OBS setup guide

.obs/workflows.yml       GitHub → OBS CI integration

branding/                openSUSE branding (ported from upstream)
  README.md              Branding architecture
  upstream-sources.md    Exact upstream package sources

scripts/                 Developer helper scripts
```

## How the Rolling Update Works

Two automatic trigger paths — zero manual intervention:

1. **You push to git** → GitHub webhook → OBS pulls new sources via `obs_scm` → rebuilds image
2. **Ubuntu pushes a package update** → OBS scheduler detects dependency change → automatic rebuild

Both produce a fresh, up-to-date image published to `download.opensuse.org`.

## Branding

The visual identity is the **real openSUSE GNOME branding**, not a custom theme:

| Layer | Source | What |
|---|---|---|
| openSUSE look | `glib2-branding-openSUSE` | Wallpapers, colors, sounds, defaults |
| Ubuntu ergonomics | Custom | Dash-to-Dock on left |

See [branding/README.md](branding/README.md) for the full architecture.

## Tech Stack

| Component | Role |
|---|---|
| **OBS** | Central orchestrator — builds, signs, publishes, auto-rebuilds |
| **KIWI-ng** | Image builder — produces deployable `.raw` disk images |
| **Ubuntu Noble 24.04** | Base system — DEB packages, apt |
| **GNOME** | Desktop environment with openSUSE branding |
| **Agama** | Installer (future phase) |

## License

GPL-2.0 — see [LICENSE](LICENSE).
