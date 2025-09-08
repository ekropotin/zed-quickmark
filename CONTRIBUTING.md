# Contributing to QuickMark Zed Extension

This document provides guidelines for contributing to the QuickMark Zed extension and information for developers who want to modify or extend the codebase.

## Development Setup

### Prerequisites

- Rust toolchain with `wasm32-wasip1` target
- Zed editor for testing

### Getting Started

1. **Clone the repository:**

   ```bash
   git clone https://github.com/ekropotin/zed-quickmark.git
   cd zed-quickmark
   ```

2. **Install Rust target:**

   ```bash
   rustup target add wasm32-wasip1
   ```

3. **Build the extension:**

   ```bash
   cargo build --release --target wasm32-wasip1
   ```

4. **Install for development:**
   - Open Zed command palette (`Cmd+Shift+P`)
   - Run "zed: install dev extension"
   - Select this directory

## Project Structure

```
zed-quickmark/
├── extension.toml          # Extension metadata and configuration
├── Cargo.toml             # Rust project configuration with server version
├── src/
│   └── lib.rs             # Main extension implementation
├── .github/workflows/     # CI/CD workflows
├── scripts/
│   └── package.sh         # Packaging script for releases
└── install.sh             # User installation script
```

## Architecture

### Core Components

**Extension Entry Point** (`src/lib.rs`):

- `QuickMarkExtension`: Main extension struct implementing Zed's Extension trait
- `get_server_path()`: Handles automatic server download and version management
- `language_server_command()`: Configures the language server command

**Version Management**:

- Server version is read directly from `Cargo.toml` metadata via Cargo's built-in `CARGO_PKG_METADATA_*` environment variables
- No build script needed - Cargo automatically provides the metadata at compile time

**Configuration** (`extension.toml`):

- Extension metadata (name, description, version)
- Language server configuration mapping QuickMark to Markdown files

### Key Features

1. **Automatic Binary Download**: Extension downloads the correct `quickmark-server` binary for the user's platform
2. **Version Locking**: Each extension version is tied to a specific server version
3. **Cross-Platform Support**: Handles macOS, Linux, and Windows binaries
4. **Automatic Updates**: When extension updates, it detects version mismatches and downloads new server versions

## Development Workflow

### Making Changes

1. **Modify the extension code** in `src/lib.rs`
2. **Update server version** (if needed) in `Cargo.toml` under `[package.metadata.quickmark]`
3. **Build and test locally:**

   ```bash
   cargo build --release --target wasm32-wasip1
   ```

4. **Test in Zed** by reinstalling the dev extension

### Version Management

The extension uses a specific `quickmark-server` version defined in `Cargo.toml`:

```toml
[package.metadata.quickmark]
server_version = "1.1.0"
```

**To update to a newer quickmark-server version:**

1. Change the version number in `Cargo.toml` under `[package.metadata.quickmark]`
2. Update the description in `extension.toml` if needed
3. Rebuild the extension
4. Test with the new version

This approach ensures:

- ✅ **Version stability** - Users get consistent, tested behavior
- ✅ **No local conflicts** - Extension always uses its specific server version
- ✅ **Automatic updates** - Extension automatically upgrades server when extension updates
- ✅ **Controlled updates** - Extensions are tested with specific server versions

### Testing

1. **Local Testing:**
   - Install the dev extension in Zed
   - Open a Markdown file
   - Verify diagnostics appear for rule violations

2. **Create test files** with various rule violations:

   ```bash
   echo '# This is a very long heading that exceeds the default line length limit and should trigger MD013 rule' > test.md
   ```

3. **Check logs** in Zed's developer console for any errors

### Building for Release

1. **Update version** in `extension.toml` and `Cargo.toml`
2. **Build the extension:**

   ```bash
   cargo build --release --target wasm32-wasip1
   ```

3. **Package for distribution:**

   ```bash
   ./scripts/package.sh
   ```

4. **Test the packaged version** by extracting and installing manually

## Release Process

### Creating a Release

1. **Tag the release:**

   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **GitHub Actions automatically:**
   - Builds the extension
   - Packages it into `.tar.gz` and `.zip` files
   - Creates a GitHub release with installation instructions

3. **Users can install via:**

   ```bash
   curl -fsSL https://github.com/ekropotin/zed-quickmark/releases/latest/download/install.sh | bash
   ```

### Release Checklist

- [ ] Server version updated in `Cargo.toml` if needed
- [ ] Extension version bumped in `extension.toml`
- [ ] Changes tested locally
- [ ] Build passes (`cargo build --release --target wasm32-wasip1`)
- [ ] Tag created and pushed
- [ ] GitHub release created successfully
- [ ] Installation script tested

## Branch Naming and Commits

Follow the branch naming conventions:

- `feature/123-description` - New features (include issue number if applicable)
- `fix/456-description` - Bug fixes
- `chore/description` - Maintenance tasks

**Commit Messages:**
If the branch name contains an issue number, include `fixes #123` in commit messages to automatically link and close the issue when merged.

```
Brief description of changes

Longer explanation if needed.

Fixes #123
```

## Code Guidelines

### Rust Best Practices

1. **Follow idiomatic Rust**: Use modern Rust features and conventions
2. **Error handling**: Use `Result` types and the `?` operator
3. **Performance**: Optimize for speed, cache expensive operations
4. **Safety**: Avoid `unwrap()` and `expect()` in production code

### Extension-Specific Guidelines

1. **Zed API compatibility**: Always use the correct `zed_extension_api` version
2. **Cross-platform support**: Test binary downloads work on all supported platforms
3. **Version management**: Ensure version checking logic is robust
4. **User experience**: Provide clear status updates during downloads

### Code Quality

Code must pass:

- `cargo check`
- `cargo clippy --all-targets --all-features -- -D warnings`
- `cargo fmt --check`

## Troubleshooting

### Common Development Issues

1. **Extension not loading**: Check Zed's log files for compilation errors
2. **Server not downloading**: Verify GitHub releases have the correct asset names
3. **Version conflicts**: Ensure `build.rs` correctly reads the version from `Cargo.toml`

### Debugging

1. **Check Zed logs** for extension loading issues
2. **Verify binary paths** are correct for the target platform
3. **Test download URLs** manually to ensure they're accessible

## Release procedure

Below are manual steps required for release, until it's not automated via Github actions.

- Update version in cargo.toml
- Update version in extension.toml
- Apply git tag with the new version and publish it on main branch - it suppored to create a GH release automatically
- Go to release notes and update them if needed

## Getting Help

- **Main Project**: [QuickMark](https://github.com/ekropotin/quickmark)
- **Issues**: Report bugs or request features in this repository's issues
- **Zed Extensions**: [Zed Extension Documentation](https://zed.dev/docs/extensions)

## License

Licensed under the same terms as the main QuickMark project.
