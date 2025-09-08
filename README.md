# QuickMark Extension for Zed

A lightning-fast Markdown linter extension for the [Zed text editor](https://zed.dev), powered by the [QuickMark](https://github.com/ekropotin/quickmark) language server.

## Features

- **Lightning-fast linting**: Built in Rust for exceptional performance
- **LSP integration**: Full Language Server Protocol support for real-time diagnostics
- **Markdown focused**: Specialized for CommonMark/Markdown files
- **Zero configuration**: Works out of the box with sensible defaults
- **Configurable**: Supports `quickmark.toml` configuration files
- **Version locked**: Always uses the exact quickmark-server version the extension was built for

## Installation

### Prerequisites

**No prerequisites needed!** The extension automatically downloads the correct `quickmark-server` binary for your platform.

### Installing the Extension

**🚀 One-line install:**

```bash
curl -fsSL https://raw.githubusercontent.com/ekropotin/zed-quickmark/main/install.sh | bash
```

**📦 Manual install:**

1. Download the latest release from [GitHub Releases](https://github.com/ekropotin/zed-quickmark/releases)
2. Extract the archive
3. Run the included `install.sh` script

**🔧 Development install:**

1. Clone this repository
2. Open Zed command palette (`Cmd+Shift+P`)
3. Run "zed: install dev extension"
4. Select this directory

**🏪 Marketplace (Coming Soon):**
The extension will be available in the [Zed Extensions marketplace](https://zed.dev/extensions) once submitted.

## Supported File Types

- `.md` - Markdown files
- `.markdown` - Markdown files
- `.mdown` - Markdown files
- `.mkd` - Markdown files
- `.mkdn` - Markdown files

## Documentation

For comprehensive information about QuickMark, including:

- **Complete rule documentation** - [Available Rules](https://github.com/ekropotin/quickmark#rules)
- **Configuration options** - [Configuration Guide](https://github.com/ekropotin/quickmark#configuration)
- **Other editor integrations** - [IDE Integrations](https://github.com/ekropotin/quickmark#ide-integrations)

Visit the main [QuickMark repository](https://github.com/ekropotin/quickmark).

## Troubleshooting

### Quick Fixes

1. **No diagnostics showing**: Ensure your file has a `.md` extension and check for `quickmark.toml` configuration
2. **Extension not loading**: Check Zed's developer console for errors
3. **Download issues**: Check your internet connection - the extension downloads the server automatically

### Testing the Extension

Create a test file with rule violations:

```bash
echo '# This is a very long heading that exceeds the default line length limit and should trigger line-length rule' > test.md
```

Open in Zed - you should see diagnostics if the extension is working.

### More Help

- **Detailed troubleshooting**: See [CONTRIBUTING.md](CONTRIBUTING.md)
- **QuickMark issues**: Check the [main project](https://github.com/ekropotin/quickmark)
- **Extension issues**: Report in this repository's [issues](https://github.com/ekropotin/zed-quickmark/issues)

## Contributing

Want to contribute? See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, architecture overview, and contribution guidelines.

## License

Licensed under the same terms as the main QuickMark project.
