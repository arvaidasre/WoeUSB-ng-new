#!/bin/bash
#
# Create desktop menu entry for WoeUSB-ng
# This script creates a proper .desktop file and integrates it into the system menu
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

log "Creating WoeUSB-ng menu entry..."

# Find where WoeUSB-ng is installed
WOEUSB_PATH=""
if command -v woeusbgui >/dev/null 2>&1; then
    WOEUSB_PATH=$(which woeusbgui)
    success "Found woeusbgui at: $WOEUSB_PATH"
elif python3 -c "import WoeUSB.gui" 2>/dev/null; then
    WOEUSB_PATH="python3 -m WoeUSB.woeusbgui"
    success "Found WoeUSB-ng Python module"
else
    error "WoeUSB-ng not found. Please install it first."
    exit 1
fi

# Choose desktop file location
if [ -w "/usr/share/applications" ] || [ "$EUID" -eq 0 ]; then
    DESKTOP_DIR="/usr/share/applications"
    ICON_DIR="/usr/share/pixmaps"
    log "Installing system-wide desktop entry"
else
    DESKTOP_DIR="$HOME/.local/share/applications"
    ICON_DIR="$HOME/.local/share/icons"
    log "Installing user desktop entry"
fi

# Create directories
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"

# Create desktop entry
DESKTOP_FILE="$DESKTOP_DIR/woeusb-ng.desktop"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=WoeUSB-ng
GenericName=Windows USB Creator
Comment=Create bootable Windows USB drives from ISO images
Icon=woeusb-ng
Exec=pkexec env DISPLAY=\$DISPLAY XAUTHORITY=\$XAUTHORITY $WOEUSB_PATH
Terminal=false
Categories=System;Utility;
Keywords=usb;windows;bootable;installer;iso;dvd;woeusb;
StartupNotify=true
MimeType=application/x-cd-image;application/x-iso9660-image;
Actions=CLI;

[Desktop Action CLI]
Name=Command Line Interface
Exec=x-terminal-emulator -e woeusb --help
EOF

# Make desktop file executable
chmod +x "$DESKTOP_FILE"
success "Created desktop entry: $DESKTOP_FILE"

# Try to copy icon
PYTHON_SITE_PACKAGES=$(python3 -c "import site; print(':'.join(site.getsitepackages() + [site.getusersitepackages()]))" 2>/dev/null || echo "")
ICON_FOUND=false

# Search for icon in various locations
for site_dir in $(echo "$PYTHON_SITE_PACKAGES" | tr ':' ' '); do
    if [ -f "$site_dir/WoeUSB/data/woeusb-logo.png" ]; then
        cp "$site_dir/WoeUSB/data/woeusb-logo.png" "$ICON_DIR/woeusb-ng.png"
        ICON_FOUND=true
        success "Copied icon to: $ICON_DIR/woeusb-ng.png"
        break
    elif [ -f "$site_dir/WoeUSB/data/icon.ico" ]; then
        cp "$site_dir/WoeUSB/data/icon.ico" "$ICON_DIR/woeusb-ng.png"
        ICON_FOUND=true
        success "Copied icon to: $ICON_DIR/woeusb-ng.png"
        break
    fi
done

if [ "$ICON_FOUND" = false ]; then
    warn "Icon not found, using default system icon"
    # Update desktop file to use default icon
    sed -i 's/Icon=woeusb-ng/Icon=drive-removable-media/' "$DESKTOP_FILE"
fi

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    if [ "$DESKTOP_DIR" = "/usr/share/applications" ]; then
        sudo update-desktop-database 2>/dev/null || true
    else
        update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
    fi
    success "Updated desktop database"
fi

# Update MIME database if possible
if command -v update-mime-database >/dev/null 2>&1; then
    if [ "$DESKTOP_DIR" = "/usr/share/applications" ]; then
        sudo update-mime-database /usr/share/mime 2>/dev/null || true
    fi
fi

# Create polkit policy for GUI privilege escalation
POLICY_FILE="/usr/share/polkit-1/actions/com.github.woeusb.woeusb-ng.policy"
if [ -d "/usr/share/polkit-1/actions" ]; then
    if [ -w "/usr/share/polkit-1/actions" ] || [ "$EUID" -eq 0 ]; then
        log "Creating polkit policy..."
        
        cat > "$POLICY_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
"http://www.freedesktop.org/software/polkit/policyconfig-1.dtd">
<policyconfig>
    <vendor>WoeUSB Project</vendor>
    <vendor_url>https://github.com/WoeUSB/WoeUSB-ng</vendor_url>
    <icon_name>woeusb-ng</icon_name>
    
    <action id="com.github.woeusb.woeusb-ng.pkexec">
        <description>Run WoeUSB-ng</description>
        <description xml:lang="pl">Uruchom WoeUSB-ng</description>
        <description xml:lang="de">WoeUSB-ng ausführen</description>
        <message>Authentication is required to run WoeUSB-ng</message>
        <message xml:lang="pl">Wymagane jest uwierzytelnienie, aby uruchomić WoeUSB-ng</message>
        <message xml:lang="de">Authentifizierung ist erforderlich, um WoeUSB-ng auszuführen</message>
        <icon_name>woeusb-ng</icon_name>
        <defaults>
            <allow_any>auth_admin</allow_any>
            <allow_inactive>auth_admin</allow_inactive>
            <allow_active>auth_admin_keep</allow_active>
        </defaults>
        <annotate key="org.freedesktop.policykit.exec.path">$(which woeusbgui || echo "python3 -m WoeUSB.woeusbgui")</annotate>
        <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
    </action>
</policyconfig>
EOF
        
        if [ "$EUID" -ne 0 ]; then
            sudo mv "$POLICY_FILE" "$POLICY_FILE.tmp" && sudo mv "$POLICY_FILE.tmp" "$POLICY_FILE"
        fi
        
        success "Created polkit policy: $POLICY_FILE"
    else
        warn "Cannot create polkit policy (no write permissions to /usr/share/polkit-1/actions)"
        warn "You may need to run this script with sudo for full GUI integration"
    fi
fi

echo ""
success "WoeUSB-ng menu entry created successfully!"
log "The application should now appear in your applications menu under 'System Tools' or 'Utilities'"
log "You can also launch it by searching for 'WoeUSB-ng' in your application launcher"

# Test if desktop file validates
if command -v desktop-file-validate >/dev/null 2>&1; then
    if desktop-file-validate "$DESKTOP_FILE" 2>/dev/null; then
        success "Desktop file validation passed"
    else
        warn "Desktop file validation failed (but it should still work)"
    fi
fi
