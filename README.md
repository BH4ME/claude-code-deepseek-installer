# Claude Code DeepSeek Installer

One-command installer for Claude Code configured to use DeepSeek's Anthropic-compatible API.

This repository does not include any API keys. Each machine must provide its own DeepSeek API key during installation.

## Quick Install

### Linux and macOS

```bash
curl -fsSL https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.sh | bash
```

Non-interactive:

```bash
curl -fsSL https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.sh | DEEPSEEK_API_KEY="<your-deepseek-api-key>" bash
```

### Windows PowerShell

```powershell
irm https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.ps1 | iex
```

Non-interactive:

```powershell
$env:DEEPSEEK_API_KEY="<your-deepseek-api-key>"
irm https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.ps1 | iex
```

## What It Does

- Installs or updates `@anthropic-ai/claude-code` with npm.
- Writes Claude Code settings to use DeepSeek:
  - `ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`
  - `ANTHROPIC_MODEL=deepseek-v4-flash`
  - `ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash`
  - `ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-flash`
  - `ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-flash`
- Preserves other existing `~/.claude/settings.json` fields.

## Requirements

- Node.js and npm must be installed.
- A DeepSeek API key.

On Windows, install Node.js from <https://nodejs.org/> or with:

```powershell
winget install OpenJS.NodeJS.LTS
```

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y nodejs npm
```

## Use

After installation, open a new terminal and run:

```bash
claude
```

If Claude Code reports an invalid model, confirm the configured model is `deepseek-v4-flash`:

```bash
cat ~/.claude/settings.json
```
