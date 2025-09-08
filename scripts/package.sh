#!/bin/bash

# Package script for QuickMark Zed Extension
set -euo pipefail

VERSION=$(grep 'version =' extension.toml | head -1 | sed 's/.*version = "\(.*\)".*/\1/')
PACKAGE_NAME="quickmark-zed-extension-v${VERSION}"

echo "📦 Packaging QuickMark Zed Extension v${VERSION}..."

# Build the extension
echo "🔨 Building extension..."
cargo build --release --target wasm32-wasip1

# Create package directory
rm -rf "dist"
mkdir -p "dist/${PACKAGE_NAME}"

# Copy extension files
echo "📋 Copying extension files..."
cp extension.toml "dist/${PACKAGE_NAME}/"
cp Cargo.toml "dist/${PACKAGE_NAME}/"
cp build.rs "dist/${PACKAGE_NAME}/"
cp -r src/ "dist/${PACKAGE_NAME}/"
cp README.md "dist/${PACKAGE_NAME}/"
cp LICENSE "dist/${PACKAGE_NAME}/" 2>/dev/null || echo "⚠️  No LICENSE file found"

# Create installation script
echo "📝 Creating installation script..."
cat > "dist/${PACKAGE_NAME}/install.sh" << 'EOF'
#!/bin/bash
set -e

# QuickMark Zed Extension Installer
echo "🚀 Installing QuickMark Zed Extension..."

# Detect Zed extensions directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    ZED_EXT_DIR="$HOME/Library/Application Support/Zed/extensions"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ZED_EXT_DIR="$HOME/.local/share/zed/extensions"
else
    ZED_EXT_DIR="$HOME/.local/share/zed/extensions"
fi

# Create extensions directory if it doesn't exist
mkdir -p "$ZED_EXT_DIR"

# Install extension
INSTALL_DIR="$ZED_EXT_DIR/quickmark"
echo "📁 Installing to: $INSTALL_DIR"

# Remove old version if exists
if [ -d "$INSTALL_DIR" ]; then
    echo "🗑️  Removing old version..."
    rm -rf "$INSTALL_DIR"
fi

# Copy extension files
mkdir -p "$INSTALL_DIR"
cp extension.toml Cargo.toml build.rs "$INSTALL_DIR/"
cp -r src/ "$INSTALL_DIR/"

echo "✅ QuickMark Zed Extension installed successfully!"
echo "📝 Restart Zed to activate the extension."
EOF

chmod +x "dist/${PACKAGE_NAME}/install.sh"

# Create archive
echo "📦 Creating distribution archive..."
cd dist
tar -czf "${PACKAGE_NAME}.tar.gz" "${PACKAGE_NAME}/"
zip -r "${PACKAGE_NAME}.zip" "${PACKAGE_NAME}/" >/dev/null

echo "✅ Package created successfully!"
echo "📁 Files created:"
echo "   - dist/${PACKAGE_NAME}.tar.gz"
echo "   - dist/${PACKAGE_NAME}.zip"
echo ""
echo "🚀 Ready for distribution!"