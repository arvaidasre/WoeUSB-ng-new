#!/bin/bash
#
# WoeUSB-ng Automatic Installation Script
# Usage: curl -sSL https://raw.githubusercontent.com/WoeUSB/WoeUSB-ng/main/install.sh | bash
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Please don't run this script as root. It will ask for sudo when needed."
        exit 1
    fi
}

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        DISTRO="rhel"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    else
        DISTRO="unknown"
    fi
    
    log_info "Detected distribution: $DISTRO"
}

# Install system dependencies
install_system_deps() {
    log_info "Installing system dependencies..."
    
    case $DISTRO in
        ubuntu|debian|linuxmint)
            sudo apt update
            sudo apt install -y \
                python3 \
                python3-pip \
                python3-venv \
                p7zip-full \
                grub2-common \
                grub-pc-bin \
                parted \
                dosfstools \
                ntfs-3g \
                libgtk-3-dev \
                libwebkit2gtk-4.0-dev \
                gir1.2-gtk-3.0 \
                python3-gi \
                python3-gi-cairo \
                gir1.2-webkit2-4.0
            ;;
        fedora)
            sudo dnf install -y \
                python3 \
                python3-pip \
                p7zip \
                p7zip-plugins \
                grub2-tools-extra \
                parted \
                dosfstools \
                ntfs-3g \
                gtk3-devel \
                webkit2gtk3-devel \
                python3-gobject \
                python3-cairo
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm \
                python \
                python-pip \
                p7zip \
                grub \
                parted \
                dosfstools \
                ntfs-3g \
                gtk3 \
                webkit2gtk \
                python-gobject \
                python-cairo
            ;;
        opensuse*)
            sudo zypper install -y \
                python3 \
                python3-pip \
                p7zip \
                grub2 \
                parted \
                dosfstools \
                ntfs-3g \
                gtk3-devel \
                webkit2gtk3-devel \
                python3-gobject \
                python3-cairo
            ;;
        *)
            log_error "Unsupported distribution: $DISTRO"
            log_info "Please install the following dependencies manually:"
            log_info "- python3, python3-pip"
            log_info "- p7zip, grub, parted, dosfstools, ntfs-3g"
            log_info "- gtk3, webkit2gtk development libraries"
            exit 1
            ;;
    esac
    
    log_success "System dependencies installed successfully"
}

# Install Python dependencies
install_python_deps() {
    log_info "Installing Python dependencies..."
    
    # Install termcolor first as it's needed by WoeUSB
    python3 -m pip install --user termcolor
    
    # Try to install wxPython
    if ! python3 -c "import wx" 2>/dev/null; then
        log_info "Installing wxPython (this may take a while)..."
        
        # Try to install from PyPI first
        if ! python3 -m pip install --user wxPython; then
            log_warning "Failed to install wxPython from PyPI, trying distribution packages..."
            
            case $DISTRO in
                ubuntu|debian|linuxmint)
                    sudo apt install -y python3-wxgtk4.0
                    ;;
                fedora)
                    sudo dnf install -y python3-wxpython4
                    ;;
                arch|manjaro)
                    sudo pacman -S --noconfirm python-wxpython
                    ;;
                opensuse*)
                    sudo zypper install -y python3-wxPython
                    ;;
                *)
                    log_error "Failed to install wxPython. Please install it manually."
                    exit 1
                    ;;
            esac
        fi
    fi
    
    log_success "Python dependencies installed successfully"
}

# Install WoeUSB-ng
install_woeusb() {
    log_info "Installing WoeUSB-ng..."
    
    # Install from PyPI
    if python3 -m pip install --user WoeUSB-ng; then
        log_success "WoeUSB-ng installed from PyPI"
    else
        log_warning "Failed to install from PyPI, installing from source..."
        
        # Install from source
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        if command -v git >/dev/null 2>&1; then
            git clone https://github.com/WoeUSB/WoeUSB-ng.git
            cd WoeUSB-ng
        else
            log_info "Git not found, downloading archive..."
            curl -L https://github.com/WoeUSB/WoeUSB-ng/archive/main.tar.gz | tar xz
            cd WoeUSB-ng-main
        fi
        
        python3 -m pip install --user .
        cd ~
        rm -rf "$TEMP_DIR"
        
        log_success "WoeUSB-ng installed from source"
    fi
}

# Setup desktop integration
setup_desktop_integration() {
    log_info "Setting up desktop integration..."
    
    # Get user's local bin directory
    LOCAL_BIN="$HOME/.local/bin"
    
    # Ensure local bin is in PATH
    if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$LOCAL_BIN:$PATH"
        log_info "Added $LOCAL_BIN to PATH in ~/.bashrc"
    fi
    
    # Create desktop entry
    DESKTOP_DIR="$HOME/.local/share/applications"
    mkdir -p "$DESKTOP_DIR"
    
    cat > "$DESKTOP_DIR/woeusb-ng.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=WoeUSB-ng
Comment=Create bootable Windows USB drives
Icon=woeusb-ng
Exec=woeusbgui
Categories=System;Utility;
Keywords=usb;windows;bootable;installer;iso;
StartupNotify=true
EOF
    
    # Copy icon if available
    ICON_DIR="$HOME/.local/share/icons/hicolor/48x48/apps"
    mkdir -p "$ICON_DIR"
    
    # Try to find and copy the icon
    PYTHON_SITE_PACKAGES=$(python3 -c "import site; print(site.USER_SITE)")
    if [ -f "$PYTHON_SITE_PACKAGES/WoeUSB/data/icon.ico" ]; then
        cp "$PYTHON_SITE_PACKAGES/WoeUSB/data/icon.ico" "$ICON_DIR/woeusb-ng.png" 2>/dev/null || true
    fi
    
    # Update desktop database
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
    fi
    
    log_success "Desktop integration set up"
}

# Setup polkit policy for GUI
setup_polkit() {
    log_info "Setting up polkit policy for GUI access..."
    
    POLICY_DIR="/usr/share/polkit-1/actions"
    if [ -d "$POLICY_DIR" ]; then
        sudo tee "$POLICY_DIR/com.github.woeusb.woeusb-ng.policy" > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
"http://www.freedesktop.org/software/polkit/policyconfig-1.dtd">
<policyconfig>
    <vendor>WoeUSB Project</vendor>
    <vendor_url>https://github.com/WoeUSB/WoeUSB-ng</vendor_url>
    <icon_name>woeusb-ng</icon_name>
    
    <action id="com.github.woeusb.woeusb-ng.pkexec">
        <description>Run WoeUSB-ng with administrative privileges</description>
        <message>Authentication is required to run WoeUSB-ng</message>
        <icon_name>woeusb-ng</icon_name>
        <defaults>
            <allow_any>auth_admin</allow_any>
            <allow_inactive>auth_admin</allow_inactive>
            <allow_active>auth_admin_keep</allow_active>
        </defaults>
        <annotate key="org.freedesktop.policykit.exec.path">/home/$USER/.local/bin/woeusbgui</annotate>
        <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
    </action>
</policyconfig>
EOF
        log_success "Polkit policy installed"
    else
        log_warning "Polkit not found, GUI may require manual privilege escalation"
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    # Check if commands are available
    if command -v woeusb >/dev/null 2>&1; then
        log_success "woeusb command line tool is available"
    else
        log_error "woeusb command not found in PATH"
        return 1
    fi
    
    if command -v woeusbgui >/dev/null 2>&1; then
        log_success "woeusbgui GUI tool is available"
    else
        log_error "woeusbgui command not found in PATH"
        return 1
    fi
    
    # Test import
    if python3 -c "import WoeUSB.miscellaneous; print('Version:', WoeUSB.miscellaneous.__version__)" 2>/dev/null; then
        log_success "WoeUSB-ng Python module is working"
    else
        log_error "Failed to import WoeUSB-ng Python module"
        return 1
    fi
    
    return 0
}

# Print usage information
print_usage() {
    log_success "Installation completed successfully!"
    echo ""
    log_info "Usage:"
    echo "  Command line: woeusb --device <ISO_FILE> <USB_DEVICE>"
    echo "  GUI:          woeusbgui"
    echo ""
    log_info "The GUI application should also appear in your application menu."
    echo ""
    log_warning "Note: You may need to log out and log back in for the PATH changes to take effect."
    log_warning "Or run: source ~/.bashrc"
    echo ""
    log_info "For help and documentation, visit:"
    echo "  https://github.com/WoeUSB/WoeUSB-ng"
}

# Main installation function
main() {
    echo ""
    log_info "WoeUSB-ng Automatic Installation Script"
    echo "========================================"
    echo ""
    
    check_root
    detect_distro
    install_system_deps
    install_python_deps
    install_woeusb
    setup_desktop_integration
    setup_polkit
    
    if verify_installation; then
        print_usage
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Run main function
main "$@"
