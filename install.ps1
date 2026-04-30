$ErrorActionPreference = "Stop"

$Model = if ($env:DEEPSEEK_MODEL) { $env:DEEPSEEK_MODEL } else { "deepseek-v4-flash" }
$BaseUrl = if ($env:DEEPSEEK_ANTHROPIC_BASE_URL) { $env:DEEPSEEK_ANTHROPIC_BASE_URL } else { "https://api.deepseek.com/anthropic" }
$InstallCcSwitch = $env:INSTALL_CC_SWITCH -eq "1"
$SkipDeepSeekConfig = $env:SKIP_DEEPSEEK_CONFIG -eq "1"

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

function Install-DeepSeekSwitcher {
  $installDir = Join-Path $HOME ".claude-deepseek"
  $scriptPath = Join-Path $installDir "switch-deepseek.ps1"
  $cmdPath = Join-Path $installDir "claude-deepseek.cmd"
  $scriptUrl = if ($env:DEEPSEEK_SWITCHER_PS1_URL) { $env:DEEPSEEK_SWITCHER_PS1_URL } else { "https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/switch-deepseek.ps1" }
  $cmdUrl = if ($env:DEEPSEEK_SWITCHER_CMD_URL) { $env:DEEPSEEK_SWITCHER_CMD_URL } else { "https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/claude-deepseek.cmd" }

  New-Item -ItemType Directory -Force -Path $installDir | Out-Null
  Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
  Invoke-WebRequest -Uri $cmdUrl -OutFile $cmdPath

  $npmPrefix = (& npm config get prefix).Trim()
  $npmCmdPath = Join-Path $npmPrefix "claude-deepseek.cmd"
  $npmPs1Path = Join-Path $npmPrefix "switch-deepseek.ps1"

  if ($npmPrefix -and (Test-Path $npmPrefix)) {
    Copy-Item $scriptPath $npmPs1Path -Force
    Set-Content -Path $npmCmdPath -Encoding ASCII -Value "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0switch-deepseek.ps1`" %*"
  }

  Write-Host "DeepSeek model switcher installed to: $installDir"
  if ($npmPrefix -and (Test-Path $npmPrefix)) {
    Write-Host "DeepSeek model switcher command installed to: $npmCmdPath"
  }
  Write-Host "Switch models with:"
  Write-Host "  claude-deepseek flash"
  Write-Host "  claude-deepseek pro"
  Write-Host "If the command is still not recognized, open a new terminal or run:"
  Write-Host "  $cmdPath flash"
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  throw "Node.js is required. Install Node.js first, then rerun this installer."
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
  throw "npm is required. Install npm first, then rerun this installer."
}

if (-not $SkipDeepSeekConfig -and -not $env:DEEPSEEK_API_KEY) {
  $secureKey = Read-Host "Enter your DeepSeek API key" -AsSecureString
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
  try {
    $env:DEEPSEEK_API_KEY = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
  }
  finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
  }
}

if (-not $SkipDeepSeekConfig -and -not $env:DEEPSEEK_API_KEY) {
  throw "DeepSeek API key is required."
}

Write-Host "Installing or updating Claude Code..."
npm install -g "@anthropic-ai/claude-code"

if (-not $SkipDeepSeekConfig) {
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
}
else {
  Write-Host "Skipped DeepSeek API configuration. Use cc-switch later to bind your DeepSeek API key and model."
}
Write-Host "Run: claude"

Install-DeepSeekSwitcher

if ($InstallCcSwitch) {
  Install-CcSwitch
}
