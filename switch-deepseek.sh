#!/usr/bin/env bash
set -euo pipefail

MODEL_ARG="${1:-}"
BASE_URL="${DEEPSEEK_ANTHROPIC_BASE_URL:-https://api.deepseek.com/anthropic}"
SETTINGS_FILE="${HOME}/.claude/settings.json"

case "${MODEL_ARG}" in
  flash|v4-flash|deepseek-v4-flash)
    MODEL="deepseek-v4-flash"
    ;;
  pro|v4-pro|deepseek-v4-pro)
    MODEL="deepseek-v4-pro"
    ;;
  --help|-h|"")
    echo "Usage: claude-deepseek <flash|pro>"
    echo ""
    echo "Switch Claude Code between DeepSeek v4 flash and pro models."
    exit 0
    ;;
  *)
    echo "Unknown model: ${MODEL_ARG}"
    echo "Use: flash or pro"
    exit 1
    ;;
esac

mkdir -p "$(dirname "${SETTINGS_FILE}")"

export SETTINGS_FILE
export MODEL
export BASE_URL

node <<'NODE'
const fs = require("fs");

const settingsFile = process.env.SETTINGS_FILE;
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
echo "Claude Code DeepSeek model set to: ${MODEL}"
echo "Run: claude"

