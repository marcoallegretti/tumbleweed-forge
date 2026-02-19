# Tumbleweed Forge — Architecture

## Three-Layer Model

Tumbleweed Forge uses a three-layer architecture to decouple branding from distribution logic and build orchestration.

```
┌───────────────────────────────────────────────────────────┐
│              Experience Layer (boot identity)              │
│  GRUB theme · Plymouth splash · os-release · wallpapers     │
│  apply-experience.sh (GRUB + Plymouth only)                │
├───────────┬───────────┬───────────┬───────────┬───────────┤
│  Ubuntu    │  Debian    │  Deepin    │ KDE Neon  │   Arch    │
│  GNOME+Dock│  GNOME     │  DDE       │ Plasma 6  │ Plasma+   │
│  apt/GDM   │  apt/GDM   │  apt/LDM   │ apt/SDDM  │ pacman    │
├───────────┴───────────┴───────────┴───────────┴───────────┤
│                     Build Layer                           │
│  KIWI-ng · OBS · CI/CD · Assembly scripts                  │
│  Profiles: disk (OEM .raw) · live (ISO .iso)               │
└───────────────────────────────────────────────────────────┘
```

### Experience Layer (`experience/`)

Boot-level identity only. Contains universal assets that apply regardless of desktop environment.

- **`overlay/`** — GRUB theme, Plymouth splash, wallpapers (as available assets), `/etc/os-release`, `/etc/issue`. No desktop-specific config.
- **`apply-experience.sh`** — Sourced by each base's `config.sh`. Handles GRUB and Plymouth activation only. Desktop configuration belongs in the base.

### Base Layer (`bases/<distro>/`)

Distribution-specific. Each supported base contains a complete KIWI description:

| File | Purpose |
|---|---|
| `appliance.kiwi` | KIWI XML: repos, bootstrap packages, image packages, profiles, users |
| `config.sh` | Post-install script (services, locale, DE config, cleanup) |
| `root/` | Base-specific overlay (dconf, GDM logo, DE-specific assets) |
| `_constraints` | OBS build resource requirements |
| `editbootinstall_arch.sh` | _(Arch only)_ EFI boot patching — Arch lacks `linuxefi` grub module |
| `iso_boot.template` | _(Arch only)_ Custom grub template for Arch kernel naming |

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

## Base Support Matrix

| Base | Desktop | Local Build | OBS Build |
|---|---|---|---|
| Ubuntu Noble 24.04 | GNOME + Ubuntu Dock | ✅ | ✅ |
| Debian Bookworm 12 | Full GNOME (task-gnome-desktop) | ✅ | ✅ |
| Deepin 23 (beige) | DDE + LightDM | ✅ | 🔧 blocked by external repo on OBS |
| KDE Neon (Ubuntu 24.04) | Plasma 6 + SDDM | ✅ | 🔧 blocked by external repo on OBS |
| Arch Linux | KDE Plasma + pacman | ✅ | ✅ (repos available on OBS) |

## Image Types

Each edition supports two KIWI profiles:

| Profile | KIWI type | Output | Use case |
|---|---|---|---|
| `disk` | `image="oem"` | `.raw.xz` | Write to disk or VM, auto-resize on first boot |
| `live` | `image="iso"` | `.iso` | USB stick / test drive, no install required |

Build with: `ci/scripts/build-local.sh <base> --profile live`

> **Arch note**: Arch uses `flags="dmsquash"` instead of `flags="overlay"` for live ISO, plus custom `editbootinstall_arch.sh` and `iso_boot.template` to handle Arch's non-standard EFI/kernel naming. See KIWI PR [#1432](https://github.com/OSInside/kiwi/pull/1432) for background.

## External Repository Constraint on OBS

For KIWI builds, repositories referenced by `appliance.kiwi` must be resolvable through OBS (`obs://...`) in home projects.

Verified errors when trying direct upstream URLs:

- `repo url not using obs:/ scheme: http://archive.neon.kde.org/user`
- `repo url not using obs:/ scheme: https://community-packages.deepin.com/beige`

Attempting to define Download on Demand (`<download .../>`) in a home project returns:

- `admin rights are required to change projects using remote resources`

Implication:

1. KDE Neon and Deepin are currently local-build editions.
2. OBS build support requires either:
   - an OBS admin-provisioned DoD/mirror project, or
   - an existing public OBS project that mirrors the upstream repo.

## Adding a New Base

1. Create `bases/<newbase>/appliance.kiwi` — packages should match the distro's native desktop
2. Create `bases/<newbase>/config.sh` — enable services, configure DE, source `/opt/forge/apply-experience.sh` for boot identity
3. Optionally create `bases/<newbase>/root/` for static overlay files (dconf, GDM logo); also inline them in `config.sh` with existence guards for OBS compatibility
4. Create `ci/obs/<newbase>/_service`
5. Add the base to the `case` statement in `ci/scripts/build-local.sh`
6. Add the base to the CI matrix in `.github/workflows/ci.yml`
7. Run `ci/scripts/obs-setup.sh <newbase> <OBS_USER>`
8. If the base uses an upstream repo not mirrored in OBS, mark it local-only in docs until an OBS mirror exists.
