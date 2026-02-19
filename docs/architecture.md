# Tumbleweed Forge — Architecture

## Three-Layer Model

Tumbleweed Forge uses a three-layer architecture to decouple branding from distribution logic and build orchestration.

```
┌─────────────────────────────────────────────┐
│           Experience Layer                   │
│  (distribution-agnostic)                     │
│  Branding · dconf · GRUB theme · Plymouth    │
│  Wallpapers · os-release · GDM logo          │
│  apply-experience.sh                         │
├──────────────┬──────────────────────────────┤
│  Base: Ubuntu │  Base: Debian │  Base: ...   │
│  (Noble 24.04)│  (Bookworm 12)│              │
│  Packages     │  Packages     │              │
│  Bootstrap    │  Bootstrap    │              │
│  Repos        │  Repos        │              │
│  config.sh    │  config.sh    │              │
├──────────────┴──────────────────────────────┤
│           Build Layer                        │
│  KIWI-ng · OBS · CI/CD · Assembly scripts    │
│  _service · project-config · project-meta    │
└─────────────────────────────────────────────┘
```

### Experience Layer (`experience/`)

Distribution-agnostic. Contains all openSUSE visual identity assets and GNOME configuration that transfer unchanged across any DEB or RPM base.

- **`overlay/`** — File tree mirroring the target filesystem. Packaged as `experience-overlay.tar.gz` by the assembly script and extracted into the image root by KIWI's `<archive>` element.
- **`apply-experience.sh`** — Sourced by each base's `config.sh` to apply runtime configuration (dconf rebuild, GRUB theme, Plymouth theme, Dash-to-Dock).

### Base Layer (`bases/<distro>/`)

Distribution-specific. Each supported base contains a complete KIWI description:

| File | Purpose |
|---|---|
| `appliance.kiwi` | KIWI XML: repos, bootstrap packages, image packages, users |
| `config.sh` | Post-install script (distro-specific services, locale, cleanup) |
| `root/` | Distro-specific overlay files (e.g., `no-snap.pref` for Ubuntu) |
| `_constraints` | OBS build resource requirements |

### Build Layer (`ci/`)

Orchestration. Per-base OBS configurations and universal build scripts.

| Path | Purpose |
|---|---|
| `ci/obs/<base>/project-meta.xml` | OBS project metadata |
| `ci/obs/<base>/project-config.txt` | OBS project config (substitute, prefer) |
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

> **OBS compatibility note:** `obs_scm` always creates `.obscpio` archives, not `.tar.gz`. KIWI's `<archive>` element requires standard tar formats, so we cannot use it on OBS. Instead, the experience overlay is pulled directly as `root.obscpio` (via `filename=root`), which KIWI handles natively as the root overlay directory. Base-specific overlay files should be created in `config.sh` rather than in a separate `root/` directory.

## Adding a New Base

1. Create `bases/<newbase>/appliance.kiwi` with distro-specific repos, packages, bootstrap
2. Create `bases/<newbase>/config.sh` — must source `/opt/forge/apply-experience.sh`
3. Create `ci/obs/<newbase>/` with project-meta, project-config, _service
4. Add the base to the `case` statement in `ci/scripts/build-local.sh`
5. Run `ci/scripts/obs-setup.sh <newbase> <OBS_USER>`
