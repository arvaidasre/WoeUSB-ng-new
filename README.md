<div align="center">
<h1>WoeUSB-ng</h1>
<img src=".github/woeusb-logo.png" alt="brand" width="28%" />

[![CI/CD](https://github.com/WoeUSB/WoeUSB-ng/actions/workflows/ci.yml/badge.svg)](https://github.com/WoeUSB/WoeUSB-ng/actions/workflows/ci.yml)
[![PyPI version](https://badge.fury.io/py/WoeUSB-ng.svg)](https://badge.fury.io/py/WoeUSB-ng)
[![Python Support](https://img.shields.io/pypi/pyversions/WoeUSB-ng.svg)](https://pypi.org/project/WoeUSB-ng/)
[![License: GPL v3+](https://img.shields.io/badge/License-GPL%20v3+-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

</div>

_A Linux program to create a Windows USB stick installer from a real Windows DVD or image._

This package contains two programs:

* **woeusb**: A command-line utility that enables you to create your own bootable Windows installation USB storage device from an existing Windows Installation disc or disk image
* **woeusbgui**: Graphic version of woeusb

Supported images:

Windows Vista, Windows 7, Window 8.x, Windows 10. All languages and any version (home, pro...) and Windows PE are supported.

Supported bootmodes:

* Legacy/MBR-style/IBM PC compatible bootmode
* Native UEFI booting is supported for Windows 7 and later images (limited to the FAT filesystem as the target)

This project rewrite of original [WoeUSB](https://github.com/slacka/WoeUSB) 

## Installation

### 🚀 One-Command Installation (Recommended)

#### Complete Installation with Menu Integration
```bash
curl -sSL https://raw.githubusercontent.com/WoeUSB/WoeUSB-ng/main/install.sh | bash
```

#### Quick Install (Python package only)
```bash
curl -sSL https://raw.githubusercontent.com/WoeUSB/WoeUSB-ng/main/quick-install.sh | bash
```

#### Windows (PowerShell as Administrator)
```powershell
irm https://raw.githubusercontent.com/WoeUSB/WoeUSB-ng/main/install.ps1 | iex
```

#### Add to Applications Menu (if not done automatically)
```bash
curl -sSL https://raw.githubusercontent.com/WoeUSB/WoeUSB-ng/main/makemenu.sh | bash
```

### Manual Installation

#### From PyPI
```bash
pip install WoeUSB-ng
```

#### From Source
```bash
git clone https://github.com/WoeUSB/WoeUSB-ng.git
cd WoeUSB-ng
pip install .
```

### Distribution Packages

#### Arch Linux
```bash
yay -S woeusb-ng
```

## Development Setup

For development work:

```shell
git clone https://github.com/WoeUSB/WoeUSB-ng.git
cd WoeUSB-ng
pip install -e ".[dev]"
```

This installs the package in editable mode with development dependencies.

## Installation from source code locally or in virtual environment 
```shell
git clone https://github.com/WoeUSB/WoeUSB-ng.git
cd WoeUSB-ng
git apply development.patch
sudo pip3 install -e .
```
Please note that this will not create menu shortcut and you may need to run gui twice as it may want to adjust policy. 

## Requirements

### Python Version
- Python 3.8 or higher

### System Dependencies
- p7zip-full (or p7zip)
- grub2-common and grub-pc-bin (or equivalent)
- parted
- dosfstools
- ntfs-3g

### Distribution-specific Installation

#### Ubuntu/Debian
```shell
sudo apt install p7zip-full grub2-common grub-pc-bin parted dosfstools ntfs-3g
```

#### Fedora
```shell
sudo dnf install p7zip p7zip-plugins grub2-tools-extra parted dosfstools ntfs-3g
```

#### Arch Linux
```shell
sudo pacman -S p7zip grub parted dosfstools ntfs-3g
```

## Uninstalling

To remove WoeUSB-ng:
```shell
pip uninstall WoeUSB-ng
```

For system-wide installations with custom files:
```shell
sudo pip uninstall WoeUSB-ng
sudo rm -f /usr/share/icons/WoeUSB-ng/icon.ico \
    /usr/share/applications/WoeUSB-ng.desktop \
    /usr/local/bin/woeusbgui
sudo rmdir /usr/share/icons/WoeUSB-ng/ 2>/dev/null || true
```

## License
WoeUSB-ng is distributed under the [GPL-3.0-or-later license](https://github.com/WoeUSB/WoeUSB-ng/blob/master/COPYING).
