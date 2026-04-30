#!/usr/bin/env bash
set -euo pipefail

MODEL="${DEEPSEEK_MODEL:-deepseek-v4-flash}"
BASE_URL="${DEEPSEEK_ANTHROPIC_BASE_URL:-https://api.deepseek.com/anthropic}"

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js is required. Install Node.js first, then rerun this installer."
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required. Install npm first, then rerun this installer."
  exit 1
fi

if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
  printf "Enter your DeepSeek API key: "
  stty -echo
  read -r DEEPSEEK_API_KEY
  stty echo
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

