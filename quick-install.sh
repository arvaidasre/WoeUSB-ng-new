#!/bin/bash
#
# WoeUSB-ng Quick Install Script
# Usage: curl -sSL https://raw.githubusercontent.com/WoeUSB/WoeUSB-ng/main/quick-install.sh | bash
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

log "WoeUSB-ng Quick Installer"
echo "========================"

# Check Python
if ! command -v python3 >/dev/null; then
    error "Python 3 is required but not installed"
    exit 1
fi

# Install pip if needed
if ! command -v pip3 >/dev/null && ! python3 -m pip --version >/dev/null 2>&1; then
    log "Installing pip..."
    curl https://bootstrap.pypa.io/get-pip.py | python3 - --user
fi

# Install WoeUSB-ng
log "Installing WoeUSB-ng..."
python3 -m pip install --user --upgrade WoeUSB-ng

# Setup PATH
LOCAL_BIN="$HOME/.local/bin"
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$LOCAL_BIN:$PATH"
    success "Added $LOCAL_BIN to PATH"
fi

# Create desktop entry
log "Creating desktop entry..."
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/woeusb-ng.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=WoeUSB-ng
GenericName=Windows USB Creator
Comment=Create bootable Windows USB drives from ISO images
Icon=drive-removable-media
Exec=env DISPLAY=:0 woeusbgui
Terminal=false
Categories=System;Utility;
Keywords=usb;windows;bootable;installer;iso;dvd;
StartupNotify=true
MimeType=application/x-cd-image;application/x-iso9660-image;
EOF

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

success "Installation completed!"
echo ""
log "Usage:"
echo "  CLI: woeusb --device <iso_file> <usb_device>"
echo "  GUI: woeusbgui (or find 'WoeUSB-ng' in applications menu)"
echo ""
warn "Note: You may need to restart your terminal or run 'source ~/.bashrc'"
warn "System dependencies may need to be installed separately:"
echo "  Ubuntu/Debian: sudo apt install p7zip-full grub2-common parted dosfstools ntfs-3g"
echo "  Fedora: sudo dnf install p7zip grub2-tools-extra parted dosfstools ntfs-3g"
echo "  Arch: sudo pacman -S p7zip grub parted dosfstools ntfs-3g"
