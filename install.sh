#!/bin/bash

# QuickMark Zed Extension - One-line installer
set -euo pipefail

REPO="ekropotin/zed-quickmark"
EXTENSION_NAME="quickmark"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS and set Zed extensions directory
case "$OSTYPE" in
    darwin*)
        ZED_EXT_DIR="$HOME/Library/Application Support/Zed/extensions"
        ;;
    linux*)
        ZED_EXT_DIR="$HOME/.local/share/zed/extensions"
        ;;
    msys*|cygwin*)
        ZED_EXT_DIR="$APPDATA/Zed/extensions"
        ;;
    *)
        ZED_EXT_DIR="$HOME/.local/share/zed/extensions"
        print_warning "Unknown OS type: $OSTYPE. Using default path: $ZED_EXT_DIR"
        ;;
esac

print_info "Installing QuickMark Zed Extension..."
print_info "Target directory: $ZED_EXT_DIR"

# Create extensions directory
mkdir -p "$ZED_EXT_DIR"

# Get latest release info
print_info "Fetching latest release information..."
LATEST_RELEASE=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null)
CURL_EXIT_CODE=$?

if [ $CURL_EXIT_CODE -ne 0 ] || [ -z "$LATEST_RELEASE" ] || echo "$LATEST_RELEASE" | grep -q '"message": "Not Found"'; then
    print_error "No releases found for $REPO"
    print_info "This usually means:"
    print_info "  1. No releases have been published yet"
    print_info "  2. The repository doesn't exist or is private"
    print_info ""
    print_info "For development installation:"
    print_info "  1. Clone the repository: git clone https://github.com/$REPO"
    print_info "  2. Open Zed and run 'zed: install dev extension'"
    print_info "  3. Select the cloned directory"
    exit 1
fi

VERSION=$(echo "$LATEST_RELEASE" | grep '"tag_name"' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep '"browser_download_url".*\.tar\.gz"' | head -1 | sed -E 's/.*"browser_download_url": "([^"]+)".*/\1/')

if [ -z "$VERSION" ] || [ -z "$DOWNLOAD_URL" ]; then
    print_error "Failed to parse release information"
    print_info "Latest release response:"
    echo "$LATEST_RELEASE"
    exit 1
fi

print_info "Latest version: $VERSION"

# Download and extract
TEMP_DIR=$(mktemp -d)
ARCHIVE_NAME="quickmark-zed-extension-${VERSION}.tar.gz"
TEMP_ARCHIVE="$TEMP_DIR/$ARCHIVE_NAME"

print_info "Downloading $ARCHIVE_NAME..."
curl -fsSL -o "$TEMP_ARCHIVE" "$DOWNLOAD_URL"

print_info "Extracting extension..."
cd "$TEMP_DIR"
tar -xzf "$ARCHIVE_NAME"

# Install extension
INSTALL_DIR="$ZED_EXT_DIR/$EXTENSION_NAME"

if [ -d "$INSTALL_DIR" ]; then
    print_info "Removing existing installation..."
    rm -rf "$INSTALL_DIR"
fi

print_info "Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

# Find extracted directory (handle version suffixes)
EXTRACTED_DIR=$(find "$TEMP_DIR" -maxdepth 1 -name "quickmark-zed-extension-*" -type d | head -1)

if [ -z "$EXTRACTED_DIR" ]; then
    print_error "Failed to find extracted extension directory"
    exit 1
fi

# Copy extension files
cp "$EXTRACTED_DIR/extension.toml" "$INSTALL_DIR/"
cp "$EXTRACTED_DIR/Cargo.toml" "$INSTALL_DIR/"
cp "$EXTRACTED_DIR/build.rs" "$INSTALL_DIR/"
cp -r "$EXTRACTED_DIR/src/" "$INSTALL_DIR/"

# Cleanup
rm -rf "$TEMP_DIR"

print_success "QuickMark Zed Extension $VERSION installed successfully!"
print_info "📝 Restart Zed to activate the extension"
print_info "🔧 The extension will automatically download quickmark-server when first used"

# Check if Zed is running
if pgrep -x "Zed" > /dev/null 2>&1; then
    print_warning "Zed is currently running. Please restart it to activate the extension."
fi
