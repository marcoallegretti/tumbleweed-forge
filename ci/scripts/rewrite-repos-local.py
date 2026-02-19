#!/usr/bin/env python3
"""Rewrite obs:// repository URLs in a KIWI appliance.kiwi to real URLs.

OBS-internal obs:// paths only resolve inside the Open Build Service.
For local and boxed builds we need actual download URLs.

Usage: rewrite-repos-local.py <base> <appliance.kiwi>
"""
import sys
import xml.etree.ElementTree as ET

REPOS = {
    "ubuntu": [
        {"alias": "kiwi-builder", "type": "apt-deb", "priority": "1",
         "architectures": "amd64",
         "path": "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/xUbuntu_24.04"},
        {"alias": "ubuntu-noble", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "noble", "components": "main restricted universe multiverse",
         "path": "http://archive.ubuntu.com/ubuntu"},
        {"alias": "ubuntu-noble-updates", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "noble-updates", "components": "main restricted universe multiverse",
         "path": "http://archive.ubuntu.com/ubuntu"},
        {"alias": "ubuntu-noble-security", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "noble-security", "components": "main restricted universe multiverse",
         "path": "http://security.ubuntu.com/ubuntu"},
    ],
    "ubuntu-native": [
        {"alias": "kiwi-builder", "type": "apt-deb", "priority": "1",
         "architectures": "amd64",
         "path": "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/xUbuntu_24.04"},
        {"alias": "ubuntu-noble", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "noble", "components": "main restricted universe multiverse",
         "path": "http://archive.ubuntu.com/ubuntu"},
        {"alias": "ubuntu-noble-updates", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "noble-updates", "components": "main restricted universe multiverse",
         "path": "http://archive.ubuntu.com/ubuntu"},
        {"alias": "ubuntu-noble-security", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "noble-security", "components": "main restricted universe multiverse",
         "path": "http://security.ubuntu.com/ubuntu"},
    ],
    "debian": [
        {"alias": "kiwi-builder", "type": "apt-deb", "priority": "1",
         "architectures": "amd64",
         "path": "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/Debian_12"},
        {"alias": "debian-bookworm", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "bookworm", "components": "main contrib non-free non-free-firmware",
         "path": "http://deb.debian.org/debian"},
        {"alias": "debian-bookworm-updates", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "bookworm-updates", "components": "main contrib non-free non-free-firmware",
         "path": "http://deb.debian.org/debian"},
        {"alias": "debian-bookworm-security", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "bookworm-security", "components": "main contrib non-free non-free-firmware",
         "path": "http://security.debian.org/debian-security"},
    ],
    "deepin": [
        {"alias": "kiwi-builder", "type": "apt-deb", "priority": "1",
         "architectures": "amd64",
         "path": "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/Debian_12"},
        {"alias": "deepin-beige", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "beige", "components": "main community",
         "path": "https://community-packages.deepin.com/beige"},
    ],
    "kde-neon": [
        {"alias": "kiwi-builder", "type": "apt-deb", "priority": "1",
         "architectures": "amd64",
         "path": "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Builder/xUbuntu_24.04"},
        {"alias": "neon-user", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "noble", "components": "main",
         "path": "http://archive.neon.kde.org/user"},
        {"alias": "ubuntu-noble", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "noble", "components": "main restricted universe multiverse",
         "path": "http://archive.ubuntu.com/ubuntu"},
        {"alias": "ubuntu-noble-updates", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "noble-updates", "components": "main restricted universe multiverse",
         "path": "http://archive.ubuntu.com/ubuntu"},
        {"alias": "ubuntu-noble-security", "type": "apt-deb",
         "architectures": "amd64",
         "distribution": "noble-security", "components": "main restricted universe multiverse",
         "path": "http://security.ubuntu.com/ubuntu"},
    ],
    "arch": [
        {"alias": "arch-core", "type": "pacman",
         "path": "https://geo.mirror.pkgbuild.com/core/os/x86_64"},
        {"alias": "arch-extra", "type": "pacman",
         "path": "https://geo.mirror.pkgbuild.com/extra/os/x86_64"},
        {"alias": "kiwi-staging", "type": "pacman",
         "path": "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Staging/Arch_Linux"},
        {"alias": "dracut-hooks", "type": "pacman",
         "path": "https://download.opensuse.org/repositories/Virtualization:/Appliances:/Images:/Testing_x86:/archlinux/standard"},
    ],
}


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <base> <appliance.kiwi>", file=sys.stderr)
        sys.exit(1)

    base = sys.argv[1]
    kiwi_file = sys.argv[2]

    if base not in REPOS:
        print(f"Warning: no local repos defined for base '{base}', skipping", file=sys.stderr)
        return

    tree = ET.parse(kiwi_file)
    root = tree.getroot()

    # Find insertion point (before first <packages>)
    insert_idx = None
    for i, child in enumerate(root):
        if child.tag == "packages":
            insert_idx = i
            break

    # Remove all existing <repository> elements
    for repo in root.findall("repository"):
        root.remove(repo)

    # Insert real-URL repos
    for j, r in enumerate(REPOS[base]):
        elem = ET.Element("repository")
        elem.set("type", r["type"])
        elem.set("alias", r["alias"])
        if "priority" in r:
            elem.set("priority", r["priority"])
        if "architectures" in r:
            elem.set("architectures", r["architectures"])
        if "distribution" in r:
            elem.set("distribution", r["distribution"])
        if "components" in r:
            elem.set("components", r["components"])
        elem.set("repository_gpgcheck", "false")
        src = ET.SubElement(elem, "source")
        src.set("path", r["path"])
        elem.tail = "\n\n    "
        src.tail = "\n    "

        if insert_idx is not None:
            root.insert(insert_idx + j, elem)
        else:
            root.append(elem)

    tree.write(kiwi_file, xml_declaration=True, encoding="utf-8")
    print(f"Rewrote repos in {kiwi_file} for local build of '{base}'")


if __name__ == "__main__":
    main()
