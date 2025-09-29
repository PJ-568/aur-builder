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

# Collect PKG files in current dir (temp_dir)
if ! ls ./*.pkg.tar.* >/dev/null 2>&1; then
  echo "Error: No .pkg.tar.* files found after build."
  exit 1
fi

output_file="../../${package_name}-${version}.tar.gz"
echo "Packaging into ${output_file}..."

tar -czf "${output_file}" *.pkg.tar.*

cd ../..

# Cleanup
rm -rf "${temp_dir}"

echo "Successfully built ${package_name}-${version}.tar.gz"
