#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
VERSION="${1:-v0.1.0}"
ARCHIVE_BASE="claude-code-deepseek-installer-${VERSION#v}"

mkdir -p "${DIST_DIR}"
rm -f "${DIST_DIR}/${ARCHIVE_BASE}.zip" "${DIST_DIR}/${ARCHIVE_BASE}.tar.gz"

tar -czf "${DIST_DIR}/${ARCHIVE_BASE}.tar.gz" -C "${ROOT_DIR}" README.md install.sh install.ps1 install.bat

if command -v zip >/dev/null 2>&1; then
  (
    cd "${ROOT_DIR}"
    zip -q "${DIST_DIR}/${ARCHIVE_BASE}.zip" README.md install.sh install.ps1 install.bat
  )
else
  echo "zip command not found; skipped .zip archive"
fi

echo "Created release assets in ${DIST_DIR}"

