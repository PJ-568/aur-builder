#!/bin/bash

set -euo pipefail

# Usage: ./build-aur.sh <package_name> [version]
# version defaults to 'latest'

package_name="${1:?Error: package_name is required. Usage: $0 <package_name> [version]}"
version="${2:-latest}"

temp_dir="temp_aur/${package_name}"
mkdir -p "$(dirname "${temp_dir}")"

echo "Cloning AUR package: ${package_name}"

git clone https://aur.archlinux.org/${package_name}.git "${temp_dir}"

cd "${temp_dir}"

if [[ "${version}" != "latest" ]]; then
  echo "Checking out version: ${version}"
  git checkout "${version}"
fi

echo "Building package with makepkg..."

makepkg -si --noconfirm

# Debug: List generated package files
echo "Debug: Current directory after makepkg: $(pwd)"
echo "Debug: Full contents of current dir ($(pwd)):"
ls -la .
echo "Debug: Package files in current dir:"
ls -la ./*.pkg.tar.* 2>/dev/null || echo "No .pkg.tar.* files found"

cd ../..

# Collect PKG files
pkg_dir="${temp_dir}"

# Debug: Confirm paths before tar
echo "Debug: Current directory before tar: $(pwd)"
echo "Debug: pkg_dir path: ${pkg_dir}"
echo "Debug: Full contents of pkg_dir (${pkg_dir}):"
ls -la "${pkg_dir}"
echo "Debug: Package files in pkg_dir before tar:"
ls -la "${pkg_dir}"/*.pkg.tar.* 2>/dev/null || echo "No .pkg.tar.* files in ${pkg_dir}"

if ! ls "${pkg_dir}"/*.pkg.tar.* >/dev/null 2>&1; then
  echo "Error: No .pkg.tar.* files found after build."
  exit 1
fi

output_file="${package_name}-${version}.tar.gz"
echo "Packaging into ${output_file}..."

tar -czf "${output_file}" -C "${pkg_dir}" *.pkg.tar.*

# Cleanup
rm -rf "${temp_dir}"

echo "Successfully built ${output_file}"