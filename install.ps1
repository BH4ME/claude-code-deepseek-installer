$ErrorActionPreference = "Stop"

$Model = if ($env:DEEPSEEK_MODEL) { $env:DEEPSEEK_MODEL } else { "deepseek-v4-flash" }
$BaseUrl = if ($env:DEEPSEEK_ANTHROPIC_BASE_URL) { $env:DEEPSEEK_ANTHROPIC_BASE_URL } else { "https://api.deepseek.com/anthropic" }
$InstallCcSwitch = $env:INSTALL_CC_SWITCH -eq "1"

function Install-CcSwitch {
  Write-Host "Fetching latest cc-switch release..."
  $release = Invoke-RestMethod -Uri "https://api.github.com/repos/farion1231/cc-switch/releases/latest" -Headers @{ "User-Agent" = "claude-code-deepseek-installer" }
  $asset = $release.assets | Where-Object { $_.name -match "Windows\.msi$" } | Select-Object -First 1

  if (-not $asset) {
    Write-Warning "No cc-switch Windows MSI asset found. Download manually from https://github.com/farion1231/cc-switch/releases/latest"
    return
  }

  $installer = Join-Path $env:TEMP $asset.name
  Write-Host "Downloading $($asset.name)..."
  Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installer

  Write-Host "Starting cc-switch installer..."
  Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installer`" /passive" -Wait
  Write-Host "cc-switch installer finished."
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  throw "Node.js is required. Install Node.js first, then rerun this installer."
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
  throw "npm is required. Install npm first, then rerun this installer."
}

if (-not $env:DEEPSEEK_API_KEY) {
  $secureKey = Read-Host "Enter your DeepSeek API key" -AsSecureString
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
  try {
    $env:DEEPSEEK_API_KEY = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  }
  finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
}

if (-not $env:DEEPSEEK_API_KEY) {
  throw "DeepSeek API key is required."
}

Write-Host "Installing or updating Claude Code..."
npm install -g "@anthropic-ai/claude-code"

$settingsDir = Join-Path $HOME ".claude"
$settingsFile = Join-Path $settingsDir "settings.json"
New-Item -ItemType Directory -Force -Path $settingsDir | Out-Null

$env:CLAUDE_SETTINGS_FILE = $settingsFile
$env:DEEPSEEK_MODEL_EFFECTIVE = $Model
$env:DEEPSEEK_BASE_URL_EFFECTIVE = $BaseUrl

@'
const fs = require("fs");

const settingsFile = process.env.CLAUDE_SETTINGS_FILE;
const token = process.env.DEEPSEEK_API_KEY;
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
'@ | node

Write-Host "Done. Claude Code is configured for DeepSeek model: $Model"
Write-Host "Run: claude"

if ($InstallCcSwitch) {
  Install-CcSwitch
}
