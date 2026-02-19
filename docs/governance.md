# Tumbleweed Forge — Branding & Governance

## Project Status

**Infrastructure Demonstrator** — not an official openSUSE product.

Tumbleweed Forge exists to showcase the portability and maturity of the openSUSE build infrastructure (OBS, KIWI-ng). It is not intended to create competitive derivatives of any distribution.

## Branding Policy

### openSUSE Assets

All openSUSE branding assets are sourced from official upstream repositories:

| Asset | Source |
|---|---|
| GNOME defaults | `glib2-branding-openSUSE` (GNOME:Factory on OBS) |
| Wallpapers | `openSUSE/branding` GitHub (Tumbleweed branch) |
| GRUB theme | `branding-openSUSE` package |
| Plymouth logo | openSUSE logo SVG converted to PNG |

### Compliance Requirements

- **Non-official status**: All images clearly identify as "Tumbleweed Forge" in `/etc/os-release`, `/etc/issue`, and boot screens
- **No confusion with official releases**: The project name and branding make clear this is a technical demonstrator
- **Trademark respect**: openSUSE trademarks are used under the community guidelines for derivative works
- **Upstream branding removal**: Base distribution branding (Ubuntu Yaru, etc.) is removed during build to avoid mixed identity

### Identity Files

The experience overlay sets these identity markers:

- `/etc/os-release` — `NAME="Tumbleweed Forge"`, `ID=tumbleweed-forge`
- `/etc/issue` — Login banner with Forge branding
- GDM greeter logo — openSUSE distributor mark
- GRUB boot splash — openSUSE theme
- Plymouth boot animation — openSUSE watermark

## Adding New Bases

When adding a new base distribution, ensure:

1. Upstream branding packages are listed in `<packages type="delete">` in the KIWI description
2. The experience overlay is referenced via `<archive name="experience-overlay.tar.gz"/>`
3. The base `config.sh` sources `/opt/forge/apply-experience.sh`
4. No base-specific theming leaks into the final image
