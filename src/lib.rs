use zed_extension_api::{self as zed, Result};

struct QuickMarkExtension {
    cached_server_path: Option<String>,
}

impl QuickMarkExtension {
    fn get_server_path(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        _worktree: &zed::Worktree,
    ) -> Result<String> {
        // Use version from Cargo.toml metadata (Cargo automatically provides this at runtime)
        let server_version = std::env::var("CARGO_PKG_METADATA_QUICKMARK_SERVER_VERSION")
            .unwrap_or_else(|_| "1.1.0".to_string());
        let version_dir = format!("quickmark-server-{}", server_version);
        let expected_binary_path = {
            let (os, _) = zed::current_platform();
            let binary_name = if matches!(os, zed::Os::Windows) {
                "quickmark-server.exe"
            } else {
                "quickmark-server"
            };
            format!("{version_dir}/{binary_name}")
        };

        // Check if cached path is still valid for current version
        if let Some(cached_path) = &self.cached_server_path {
            if cached_path == &expected_binary_path && std::fs::metadata(cached_path).is_ok() {
                return Ok(cached_path.clone());
            } else {
                // Cached path is outdated, clear it
                self.cached_server_path = None;
            }
        }

        // Always download the specific version baked into the extension
        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::CheckingForUpdate,
        );

        let version_tag = format!("quickmark-server@{}", server_version);

        let (os, arch) = zed::current_platform();
        let asset_name = match (os, arch) {
            (zed::Os::Mac, zed::Architecture::Aarch64) => {
                "quickmark-server-aarch64-apple-darwin.tar.gz"
            }
            (zed::Os::Mac, zed::Architecture::X8664) => {
                "quickmark-server-x86_64-apple-darwin.tar.gz"
            }
            (zed::Os::Linux, zed::Architecture::X8664) => {
                "quickmark-server-x86_64-unknown-linux-gnu.tar.gz"
            }
            (zed::Os::Linux, zed::Architecture::Aarch64) => {
                "quickmark-server-aarch64-unknown-linux-gnu.tar.gz"
            }
            (zed::Os::Windows, zed::Architecture::X8664) => {
                "quickmark-server-x86_64-pc-windows-msvc.tar.gz"
            }
            _ => return Err(format!("Unsupported platform: {:?} {:?}", os, arch).into()),
        };

        // Construct download URL manually for specific version
        let download_url = format!(
            "https://github.com/ekropotin/quickmark/releases/download/{}/{}",
            version_tag, asset_name
        );

        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::Downloading,
        );

        // Check if we need to download the binary
        let needs_download = if let Ok(_metadata) = std::fs::metadata(&expected_binary_path) {
            // Binary exists, but check if it's the right version by checking the parent directory
            let current_version_dir = std::path::Path::new(&expected_binary_path)
                .parent()
                .and_then(|p| p.file_name())
                .and_then(|n| n.to_str())
                .unwrap_or("");

            // Download if the version directory doesn't match our expected version
            current_version_dir != version_dir
        } else {
            // Binary doesn't exist, need to download
            true
        };

        if needs_download {
            // Clean up old versions before downloading new one
            // This prevents accumulation of old server versions
            if let Ok(entries) = std::fs::read_dir(".") {
                for entry in entries.flatten() {
                    if let Some(name) = entry.file_name().to_str() {
                        if name.starts_with("quickmark-server-") && name != version_dir {
                            let _ = std::fs::remove_dir_all(entry.path());
                        }
                    }
                }
            }

            let _downloaded_bytes = zed::download_file(
                &download_url,
                &version_dir,
                zed::DownloadedFileType::GzipTar,
            )?;

            zed::make_file_executable(&expected_binary_path)?;

            // Verify the binary was extracted successfully
            if !std::fs::metadata(&expected_binary_path).is_ok() {
                return Err(format!(
                    "Failed to install quickmark-server {}: binary not found after extraction",
                    server_version
                )
                .into());
            }
        }

        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::None,
        );

        self.cached_server_path = Some(expected_binary_path.clone());
        Ok(expected_binary_path)
    }
}

impl zed::Extension for QuickMarkExtension {
    fn new() -> Self {
        Self {
            cached_server_path: None,
        }
    }

    fn language_server_command(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        let command = self.get_server_path(language_server_id, worktree)?;

        Ok(zed::Command {
            command,
            args: vec![],
            env: Default::default(),
        })
    }
}

zed::register_extension!(QuickMarkExtension);
