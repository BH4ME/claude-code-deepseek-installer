$ErrorActionPreference = "Stop"

$Model = if ($env:DEEPSEEK_MODEL) { $env:DEEPSEEK_MODEL } else { "deepseek-v4-flash" }
$BaseUrl = if ($env:DEEPSEEK_ANTHROPIC_BASE_URL) { $env:DEEPSEEK_ANTHROPIC_BASE_URL } else { "https://api.deepseek.com/anthropic" }

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

$settings = [ordered]@{}
if (Test-Path $settingsFile) {
  try {
    $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json -AsHashtable
  }
  catch {
    $backup = "$settingsFile.bak.$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
    Copy-Item $settingsFile $backup
    Write-Warning "Existing settings were invalid JSON. Backed up to $backup"
    $settings = [ordered]@{}
  }
}

if (-not $settings.ContainsKey("env") -or -not $settings["env"]) {
  $settings["env"] = [ordered]@{}
}

$settings["env"]["ANTHROPIC_BASE_URL"] = $BaseUrl
$settings["env"]["ANTHROPIC_AUTH_TOKEN"] = $env:DEEPSEEK_API_KEY
$settings["env"]["ANTHROPIC_MODEL"] = $Model
$settings["env"]["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = $Model
$settings["env"]["ANTHROPIC_DEFAULT_SONNET_MODEL"] = $Model
$settings["env"]["ANTHROPIC_DEFAULT_OPUS_MODEL"] = $Model

if (-not $settings.ContainsKey("includeCoAuthoredBy")) {
  $settings["includeCoAuthoredBy"] = $false
}

$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsFile -Encoding UTF8

Write-Host "Done. Claude Code is configured for DeepSeek model: $Model"
Write-Host "Run: claude"

