# Releasing QuickMark Zed Extension

## Release Process

### 1. Update Version
Update the version in key files:

```bash
# Update extension.toml
sed -i 's/version = ".*"/version = "0.2.0"/' extension.toml

# Update quickmark-server version if needed  
sed -i 's/server_version = ".*"/server_version = "1.2.0"/' Cargo.toml
```

### 2. Test the Extension
```bash
# Build and test
cargo build --release --target wasm32-wasip1

# Test installation locally
./scripts/package.sh
# Test the generated installer
```

### 3. Create Release
```bash
# Commit changes
git add .
git commit -m "Release v0.2.0"

# Create and push tag
git tag v0.2.0
git push origin main --tags
```

### 4. GitHub Actions
The release workflow automatically:
- ✅ Builds the extension 
- ✅ Packages for distribution
- ✅ Creates GitHub release
- ✅ Uploads installation archives

### 5. Post-Release
- Update README if needed
- Announce in community channels
- Consider submitting to Zed marketplace

## Distribution Strategy

### Current: Direct Distribution
- ✅ **Fast updates**: No PR review bottleneck
- ✅ **Full control**: Own the release process
- ✅ **User-friendly**: One-line installer
- ✅ **Automated**: GitHub Actions handle packaging

### Future: Marketplace Submission
- Submit to [zed-industries/extensions](https://github.com/zed-industries/extensions)
- Users can discover via built-in extension browser
- Zed handles automatic updates

## Installation Methods Users Get

1. **One-line installer**:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/ekropotin/zed-quickmark/main/install.sh | bash
   ```

2. **Manual download**: GitHub Releases page

3. **Development**: Direct extension installation in Zed