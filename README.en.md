# AUR Builder

> ENGLISH | [简体中文](README.md)

aur-builder is designed to compile AUR software into .pkg.tar.zst installation package format that can be installed by the pacman package manager using GitHub Actions.

## Project Overview

This tool automates cloning specified packages from the AUR, building them with makepkg, and packaging the results into .tar.gz files for easy distribution and installation. It is suitable for Arch Linux users or developers integrating AUR builds in CI/CD pipelines.

### Features

- Supports manual build triggering (workflow_dispatch).
- Allows specifying package name, version, and architecture.
- Runs in an Arch Linux container to ensure compatibility.
- Outputs PKG files that can be directly installed via `pacman -U`.
- Automatically uploads artifacts for easy download.

### Prerequisites

- GitHub account and repository (fork this project).
- Basic understanding of Arch Linux and AUR.
- The target system must have pacman installed to use the output packages.

## Usage Guide

### Step 1: Fork the Repository

1. Visit the [GitHub repository](https://github.com/your-username/aur-builder) (replace with your fork).
2. Click "Fork" to create a copy.

### Step 2: Trigger the Build

1. On the repository page, navigate to the **Actions** tab.
2. Select the **Build AUR Package** workflow.
3. Click **Run workflow**.
4. In the input form, fill in:
   - **package_name**: AUR package name (required, e.g., `yay`).
   - **version**: Version or git tag/branch (optional, default `latest`).
   - **arch**: Target architecture (optional, default `x86_64`).
5. Click **Run workflow** to start the build.

### Step 3: Download and Install

1. After the build completes, go to **Actions** > Select the run > **Artifacts**.
2. Download `aur-package-{package_name}-{version}.tar.gz`.
3. Extract the file: `tar -xzf aur-package-*.tar.gz`.
4. Install the package: `sudo pacman -U *.pkg.tar.zst`.

### Example

Building the `yay` package:

- package_name: `yay`
- version: `latest` (or a specific tag like `v12.0.5`)
- arch: `x86_64`

Output file: `yay-latest.tar.gz`, containing `yay-12.0.5-1-x86_64.pkg.tar.zst`.

## Customization and Extension

- **Modify scripts**: Edit [scripts/build-aur.sh](scripts/build-aur.sh) to add custom logic (e.g., pre-build hooks).
- **Workflow adjustments**: Modify [.github/workflows/build-aur.yml](.github/workflows/build-aur.yml) to support auto-triggering or multi-package builds.
- **Caching**: Future additions can include actions/cache to speed up repeated builds.

## Troubleshooting

- **Build failure**: Check the Actions logs. Common issues include missing dependencies (ensure the container has base-devel) or unreachable AUR repository.
- **No PKG file**: makepkg may fail due to signing or dependency issues. Check the script output.
- **Permission errors**: Ensure running in an Arch environment with a non-root user for building.
- **Version does not exist**: Confirm the git checkout tag/branch is valid.

If issues persist, check [docs/design.md](docs/design.md) or submit an issue.

## Contributing

1. Fork the repository.
2. Create a branch: `git checkout -b feature/new-feature`.
3. Commit changes: `git commit -m "Add new feature"` (follow commit guidelines).
4. Push the branch: `git push origin feature/new-feature`.
5. Submit a Pull Request.

Contributions to script improvements, tests, or documentation updates are welcome!

## License

MIT License. See the LICENSE file for details.

## Related Resources

- [AUR Official Site](https://aur.archlinux.org/)
- [makepkg Manual](https://man.archlinux.org/man/makepkg.8)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
