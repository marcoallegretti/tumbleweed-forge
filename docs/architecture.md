# Tumbleweed Forge — Architecture

## Three-Layer Model

Tumbleweed Forge uses a three-layer architecture to decouple branding from distribution logic and build orchestration.

```
┌─────────────────────────────────────────────┐
│         Experience Layer (boot identity)      │
│  GRUB theme · Plymouth splash · os-release    │
│  Wallpapers (available) · /etc/issue           │
│  apply-experience.sh (GRUB + Plymouth only)    │
├──────────────┬──────────────────────────────┤
│  Base: Ubuntu │  Base: Debian │  Base: Deepin│
│  GNOME+Dock   │  Vanilla GNOME│  DDE         │
│  dconf+GDM    │  wallpaper ID │  LightDM     │
│  config.sh    │  config.sh    │  config.sh   │
│  root/ overlay│  root/ overlay│              │
├──────────────┴──────────────────────────────┤
│           Build Layer                        │
│  KIWI-ng · OBS · CI/CD · Assembly scripts    │
│  _service · project-config · project-meta    │
└─────────────────────────────────────────────┘
```

### Experience Layer (`experience/`)

Boot-level identity only. Contains universal assets that apply regardless of desktop environment.

- **`overlay/`** — GRUB theme, Plymouth splash, wallpapers (as available assets), `/etc/os-release`, `/etc/issue`. No desktop-specific config.
- **`apply-experience.sh`** — Sourced by each base's `config.sh`. Handles GRUB and Plymouth activation only. Desktop configuration belongs in the base.

### Base Layer (`bases/<distro>/`)

Distribution-specific. Each supported base contains a complete KIWI description:

| File | Purpose |
|---|---|
| `appliance.kiwi` | KIWI XML: repos, bootstrap packages, image packages, users |
| `config.sh` | Post-install script (services, locale, DE config, cleanup) |
| `root/` | Base-specific overlay (dconf, GDM logo, DE-specific assets) |
| `_constraints` | OBS build resource requirements |

### Build Layer (`ci/`)

Orchestration. Per-base OBS configurations and universal build scripts.

| Path | Purpose |
|---|---|
| `ci/obs/project-meta.xml` | Shared OBS project metadata |
| `ci/obs/project-config.txt` | Shared OBS project config |
| `ci/obs/<base>/_service` | OBS source service (pulls from GitHub) |
| `ci/scripts/assemble.sh` | Merges experience + base into KIWI build dir |
| `ci/scripts/build-local.sh` | Local KIWI build with repo injection |
| `ci/scripts/obs-setup.sh` | OBS project creation automation |
| `ci/scripts/test-image.sh` | QEMU boot test |

## Build Flow

### Local Build

```
ci/scripts/build-local.sh ubuntu
  └─► ci/scripts/assemble.sh ubuntu
       ├─ copies bases/ubuntu/{appliance.kiwi,config.sh}
       └─ merges experience/overlay/ into root/ directory
  └─► kiwi-ng system build --description _build/ubuntu/ --add-repo ...
```

### OBS Build

```
git push → OBS obs_scm source service
  ├─ extracts bases/ubuntu/{appliance.kiwi,config.sh}
  └─ pulls experience/overlay/ as root.obscpio
       → KIWI extracts as the root filesystem overlay
```

> **OBS compatibility note:** `obs_scm` creates `.obscpio` archives. The shared experience overlay is pulled as `root.obscpio` (via `filename=root`), which KIWI handles natively. Since OBS can only produce one `root.obscpio`, base-specific overlay files (dconf, GDM logo) are also created inline by `config.sh` with existence guards — so local builds use the files from `assemble.sh` merging, while OBS builds create them on the fly.

## Adding a New Base

1. Create `bases/<newbase>/appliance.kiwi` — packages should match the distro's native desktop
2. Create `bases/<newbase>/config.sh` — enable services, configure DE, source `/opt/forge/apply-experience.sh` for boot identity
3. Optionally create `bases/<newbase>/root/` for static overlay files (dconf, GDM logo); also inline them in `config.sh` with existence guards for OBS compatibility
4. Create `ci/obs/<newbase>/_service`
5. Add the base to the `case` statement in `ci/scripts/build-local.sh`
6. Add the base to the CI matrix in `.github/workflows/ci.yml`
7. Run `ci/scripts/obs-setup.sh <newbase> <OBS_USER>`
