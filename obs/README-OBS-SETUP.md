# OBS Project Setup Guide

Step-by-step instructions to set up the Tumbleweed Forge build pipeline on the Open Build Service.

## Prerequisites

1. **openSUSE account** — sign up at [build.opensuse.org](https://build.opensuse.org) (free)
2. **`osc` installed** — the OBS command-line client
   - openSUSE/SUSE: `sudo zypper install osc`
   - Debian/Ubuntu: `pip install osc`
   - First run will prompt for your OBS credentials
3. **GitHub personal access token** (for webhook integration, optional)

## Quick Setup (Automated)

```bash
./scripts/obs-setup.sh Mighty23
```

This creates the project, sets the config, creates the package, and uploads the `_service` file.

## Manual Setup

### Step 1: Create the OBS Project

```bash
osc meta prj -e home:Mighty23:TumbleweedForge
```

Paste the content from `obs/project-meta.xml`.

Key settings in the project meta:
- **`rebuild="transitive"`** — OBS automatically rebuilds when upstream Ubuntu packages change (this is the rolling update mechanism)
- **`block="local"`** — only block on packages within this project
- **`Virtualization:Appliances:Builder/Factory`** — provides KIWI-ng build tooling
- **`Ubuntu:24.04/universe`** — provides Ubuntu Noble packages

> **Note**: Verify the exact OBS path for Ubuntu Noble. If `Ubuntu:24.04` doesn't exist, you may need Download-on-Demand (DoD) repos.

### Step 2: Set the Project Configuration

```bash
osc meta prjconf -e home:Mighty23:TumbleweedForge
```

Paste the content from `obs/project-config.txt`.

- **`Type: kiwi`** — tells OBS this is a KIWI image build
- **`Repotype: staticlinks`** — creates stable download URLs that don't change with rebuilds
- **`Prefer:`** lines resolve dependency conflicts (add more as needed during builds)

### Step 3: Create the Package

```bash
osc meta pkg -e home:Mighty23:TumbleweedForge tumbleweed-forge-image
```

Fill in a title and description.

### Step 4: Upload the Source Service

```bash
osc checkout home:Mighty23:TumbleweedForge tumbleweed-forge-image
cd home:Mighty23:TumbleweedForge/tumbleweed-forge-image
cp /path/to/obs/_service .
osc add _service
osc commit -m "Initial: obs_scm integration with GitHub"
```

OBS will immediately pull sources from Git and trigger a build.

### Step 5: Set Up GitHub Webhook (Optional but Recommended)

This makes OBS rebuild automatically on every `git push`.

**5a. Create an OBS workflow token:**
```bash
osc token --create --operation workflow --scm-token YOUR_GITHUB_PAT
```

Note the `id` and `token` from the response.

**5b. Add webhook in GitHub repo settings:**
- Settings → Webhooks → Add webhook
- Payload URL: `https://build.opensuse.org/trigger/workflow?id=YOUR_TOKEN_ID`
- Content type: `application/json`
- Secret: `your_obs_token_secret`
- Events: Push, Pull Request

**5c. The `.obs/workflows.yml` file** in the repo root defines what happens:
- Push to `main` → triggers `obs_scm` to pull latest sources → rebuild
- Pull request → branches the package for test build

## Verify

After setup, check:
- Build status: `https://build.opensuse.org/project/show/home:Mighty23:TumbleweedForge`
- Download URL: `https://download.opensuse.org/repositories/home:/Mighty23:/TumbleweedForge/images/`

## Troubleshooting

### "unresolvable: have choice for PACKAGE: PKG_A PKG_B"

Add a `Prefer:` line to the project config:
```bash
osc meta prjconf -e home:Mighty23:TumbleweedForge
# Add: Prefer: PKG_A
```

### Build fails with missing packages

Check that the Ubuntu:24.04 repository path is correct. Try browsing:
`https://build.opensuse.org/project/show/Ubuntu:24.04`

### obs_scm fails to pull from Git

Ensure the Git URL in `obs/_service` is a public HTTPS URL (not SSH).
