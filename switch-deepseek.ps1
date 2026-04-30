$ErrorActionPreference = "Stop"

$ModelArg = if ($args.Count -gt 0) { $args[0] } else { "" }
$BaseUrl = if ($env:DEEPSEEK_ANTHROPIC_BASE_URL) { $env:DEEPSEEK_ANTHROPIC_BASE_URL } else { "https://api.deepseek.com/anthropic" }

switch ($ModelArg) {
  { $_ -in @("flash", "v4-flash", "deepseek-v4-flash") } { $Model = "deepseek-v4-flash"; break }
  { $_ -in @("pro", "v4-pro", "deepseek-v4-pro") } { $Model = "deepseek-v4-pro"; break }
  { $_ -in @("--help", "-h", "") } {
    Write-Host "Usage: .\switch-deepseek.ps1 <flash|pro>"
    Write-Host ""
    Write-Host "Switch Claude Code between DeepSeek v4 flash and pro models."
    exit 0
  }
  default {
    throw "Unknown model: $ModelArg. Use: flash or pro"
  }
}

$settingsDir = Join-Path $HOME ".claude"
$settingsFile = Join-Path $settingsDir "settings.json"
New-Item -ItemType Directory -Force -Path $settingsDir | Out-Null

$env:CLAUDE_SETTINGS_FILE = $settingsFile
$env:DEEPSEEK_MODEL_EFFECTIVE = $Model
$env:DEEPSEEK_BASE_URL_EFFECTIVE = $BaseUrl

@'
const fs = require("fs");

const settingsFile = process.env.CLAUDE_SETTINGS_FILE;
const model = process.env.DEEPSEEK_MODEL_EFFECTIVE;
const baseUrl = process.env.DEEPSEEK_BASE_URL_EFFECTIVE;

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
'@ | node

Write-Host "Claude Code DeepSeek model set to: $Model"
Write-Host "Run: claude"

