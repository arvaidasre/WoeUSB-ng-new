# WoeUSB-ng Windows Installation Script
# Usage: powershell -c "irm https://raw.githubusercontent.com/WoeUSB/WoeUSB-ng/main/install.ps1 | iex"

$ErrorActionPreference = "Stop"

Write-Host "WoeUSB-ng Windows Installer" -ForegroundColor Blue
Write-Host "===========================" -ForegroundColor Blue

# Check if running on Windows
if ($env:OS -ne "Windows_NT") {
    Write-Host "This script is for Windows only. Use install.sh on Linux." -ForegroundColor Red
    exit 1
}

# Check if Python is installed
try {
    $pythonVersion = python --version 2>$null
    Write-Host "Found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "Python is required but not found. Please install Python 3.8+ from python.org" -ForegroundColor Red
    Start-Process "https://www.python.org/downloads/"
    exit 1
}

# Check Python version
$version = python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
if ([float]$version -lt 3.8) {
    Write-Host "Python 3.8 or higher is required. Found: $version" -ForegroundColor Red
    exit 1
}

# Install WoeUSB-ng
Write-Host "Installing WoeUSB-ng..." -ForegroundColor Yellow
try {
    python -m pip install --user --upgrade WoeUSB-ng
    Write-Host "WoeUSB-ng installed successfully!" -ForegroundColor Green
} catch {
    Write-Host "Failed to install WoeUSB-ng: $_" -ForegroundColor Red
    exit 1
}

# Create desktop shortcut
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "WoeUSB-ng.lnk"

$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "python"
$Shortcut.Arguments = "-m WoeUSB.woeusbgui"
$Shortcut.Description = "WoeUSB-ng - Windows USB Creator"
$Shortcut.IconLocation = "shell32.dll,8"
$Shortcut.Save()

Write-Host "Desktop shortcut created: $shortcutPath" -ForegroundColor Green

Write-Host ""
Write-Host "Installation completed!" -ForegroundColor Green
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  GUI: Double-click the desktop shortcut or run 'python -m WoeUSB.woeusbgui'"
Write-Host "  CLI: python -m WoeUSB.woeusb --help"
Write-Host ""
Write-Host "Note: You may need additional tools like 7-Zip for full functionality" -ForegroundColor Yellow
