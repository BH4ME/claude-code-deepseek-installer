#!/usr/bin/env bash
set -euo pipefail

MODEL="${DEEPSEEK_MODEL:-deepseek-v4-flash}"
BASE_URL="${DEEPSEEK_ANTHROPIC_BASE_URL:-https://api.deepseek.com/anthropic}"
INSTALL_CC_SWITCH="${INSTALL_CC_SWITCH:-0}"

for arg in "$@"; do
  case "${arg}" in
    --with-cc-switch)
      INSTALL_CC_SWITCH="1"
      ;;
    --help|-h)
      echo "Usage: install.sh [--with-cc-switch]"
      echo ""
      echo "Environment:"
      echo "  DEEPSEEK_API_KEY                 DeepSeek API key"
      echo "  DEEPSEEK_MODEL                   Model name, default: deepseek-v4-flash"
      echo "  DEEPSEEK_ANTHROPIC_BASE_URL      API base URL"
      echo "  INSTALL_CC_SWITCH=1              Also install cc-switch"
      exit 0
      ;;
  esac
done

install_cc_switch() {
  local os arch asset_pattern install_dir target url

  os="$(uname -s)"
  arch="$(uname -m)"

  if [ "${os}" != "Linux" ]; then
    echo "cc-switch auto-install from this script currently supports Linux only."
    echo "Download other platforms from: https://github.com/farion1231/cc-switch/releases/latest"
    return 0
  fi

  case "${arch}" in
    x86_64|amd64)
      asset_pattern="Linux-x86_64.AppImage$"
      ;;
    arm64|aarch64)
      asset_pattern="Linux-arm64.AppImage$"
      ;;
    *)
      echo "Unsupported Linux architecture for cc-switch AppImage: ${arch}"
      echo "Download manually from: https://github.com/farion1231/cc-switch/releases/latest"
      return 0
      ;;
  esac

  echo "Fetching latest cc-switch release..."
  url="$(ASSET_PATTERN="${asset_pattern}" node <<'NODE'
const https = require("https");

const pattern = new RegExp(process.env.ASSET_PATTERN);

https.get("https://api.github.com/repos/farion1231/cc-switch/releases/latest", {
  headers: { "User-Agent": "claude-code-deepseek-installer" },
}, (res) => {
  let body = "";
  res.on("data", (chunk) => body += chunk);
  res.on("end", () => {
    const release = JSON.parse(body);
    const asset = release.assets.find((item) => pattern.test(item.name));
    if (!asset) {
      console.error("No matching cc-switch asset found.");
      process.exit(1);
    }
    process.stdout.write(asset.browser_download_url);
  });
}).on("error", (error) => {
  console.error(error.message);
  process.exit(1);
});
NODE
)"

  install_dir="${HOME}/.local/bin"
  target="${install_dir}/cc-switch"
  mkdir -p "${install_dir}"
  curl -fL "${url}" -o "${target}"
  chmod +x "${target}"

  echo "cc-switch installed to: ${target}"
  if [[ ":${PATH}:" != *":${install_dir}:"* ]]; then
    echo "Add this to your shell profile if cc-switch is not found:"
    echo "export PATH=\"${install_dir}:\$PATH\""
  fi
  echo "Run cc-switch with: ${target}"
}

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required. Install Node.js first, then rerun this installer."
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required. Install npm first, then rerun this installer."
  exit 1
fi

if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
  if [ ! -r /dev/tty ]; then
    echo "DeepSeek API key is required. Set DEEPSEEK_API_KEY for non-interactive installs."
    exit 1
  fi
  printf "Enter your DeepSeek API key: "
  stty -echo < /dev/tty
  read -r DEEPSEEK_API_KEY < /dev/tty
  stty echo < /dev/tty
  printf "\n"
fi

if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
  echo "DeepSeek API key is required."
  exit 1
fi

echo "Installing or updating Claude Code..."
npm install -g @anthropic-ai/claude-code

SETTINGS_DIR="${HOME}/.claude"
SETTINGS_FILE="${SETTINGS_DIR}/settings.json"
mkdir -p "${SETTINGS_DIR}"

export SETTINGS_FILE
export DEEPSEEK_API_KEY
export MODEL
export BASE_URL

node <<'NODE'
const fs = require("fs");

const settingsFile = process.env.SETTINGS_FILE;
const token = process.env.DEEPSEEK_API_KEY;
const model = process.env.MODEL;
const baseUrl = process.env.BASE_URL;

let settings = {};
if (fs.existsSync(settingsFile)) {
  try {
    settings = JSON.parse(fs.readFileSync(settingsFile, "utf8"));
  } catch (error) {
    const backup = `${settingsFile}.bak.${Date.now()}`;
    fs.copyFileSync(settingsFile, backup);
    console.warn(`Existing settings were invalid JSON. Backed up to ${backup}`);
  }
}

settings.env = {
  ...(settings.env || {}),
  ANTHROPIC_BASE_URL: baseUrl,
  ANTHROPIC_AUTH_TOKEN: token,
  ANTHROPIC_MODEL: model,
  ANTHROPIC_DEFAULT_HAIKU_MODEL: model,
  ANTHROPIC_DEFAULT_SONNET_MODEL: model,
  ANTHROPIC_DEFAULT_OPUS_MODEL: model,
};

if (settings.includeCoAuthoredBy === undefined) {
  settings.includeCoAuthoredBy = false;
}

fs.writeFileSync(settingsFile, `${JSON.stringify(settings, null, 2)}\n`, { mode: 0o600 });
NODE

chmod 600 "${SETTINGS_FILE}" || true

echo "Done. Claude Code is configured for DeepSeek model: ${MODEL}"
echo "Run: claude"

if [ "${INSTALL_CC_SWITCH}" = "1" ]; then
  install_cc_switch
fi
