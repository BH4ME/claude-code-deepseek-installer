# Claude Code DeepSeek Installer

一键安装 Claude Code，并把 Claude Code 配置为使用 DeepSeek 的 Anthropic-compatible API。

这个仓库不会保存、提交或发布任何 API key。安装时需要你在自己的电脑或服务器上输入 DeepSeek API key，或者通过环境变量临时传入。

## 推荐方式

推荐直接使用本仓库的一键安装脚本，不必安装 cc-switch：

1. 安装 Claude Code CLI。
2. 自动绑定 DeepSeek API。
3. 使用内置 `claude-deepseek` 工具在 `deepseek-v4-flash` 和 `deepseek-v4-pro` 之间切换。

cc-switch 仍然是可选项，适合你想用图形界面管理 provider 的情况。

## 功能

- 安装或更新 `@anthropic-ai/claude-code`
- 写入 Claude Code 配置文件：
  - Linux/macOS: `~/.claude/settings.json`
  - Windows: `%USERPROFILE%\.claude\settings.json`
- 默认绑定 DeepSeek：
  - API 地址：`https://api.deepseek.com/anthropic`
  - 模型：`deepseek-v4-flash`
- 保留已有 `settings.json` 里的其他配置项
- 自动安装 DeepSeek 模型切换工具，可以在 `deepseek-v4-flash` 和 `deepseek-v4-pro` 之间切换
- 可选安装 `cc-switch`，用于图形界面切换和管理 Claude Code provider

## 准备 DeepSeek API Key

1. 打开 DeepSeek 控制台。
2. 创建或复制你的 API key。
3. 不要把 API key 写进 README、截图、GitHub issue、release notes 或公开脚本。
4. 安装时按提示粘贴 API key，或用 `DEEPSEEK_API_KEY` 环境变量传入。

## Linux 部署（推荐）

### 1. 安装 Node.js 和 npm

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install -y nodejs npm
```

确认安装成功：

```bash
node -v
npm -v
```

### 2. 运行一键安装

交互式安装，会提示输入 DeepSeek API key：

```bash
curl -fsSL https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.sh | bash
```

非交互式安装，适合服务器初始化脚本：

```bash
curl -fsSL https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.sh | DEEPSEEK_API_KEY="<your-deepseek-api-key>" bash
```

可选：同时安装 cc-switch：

```bash
curl -fsSL https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.sh | bash -s -- --with-cc-switch
```

可选：非交互式安装并同时安装 cc-switch：

```bash
curl -fsSL https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.sh | DEEPSEEK_API_KEY="<your-deepseek-api-key>" INSTALL_CC_SWITCH=1 bash
```

可选：先不输入 API key，只安装 Claude Code 和 cc-switch，之后用 cc-switch 绑定 DeepSeek：

```bash
curl -fsSL https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.sh | SKIP_DEEPSEEK_CONFIG=1 INSTALL_CC_SWITCH=1 bash
```

### 3. 验证 Claude Code

```bash
claude --version
claude
```

进入 Claude Code 后可以测试：

```text
你当前使用的是什么模型？
```

## Windows 部署（推荐）

### 1. 安装 Node.js 和 npm

推荐使用 PowerShell：

```powershell
winget install OpenJS.NodeJS.LTS
```

也可以从 Node.js 官网安装：<https://nodejs.org/>

安装后重新打开 PowerShell，确认：

```powershell
node -v
npm -v
```

### 2. 运行一键安装

交互式安装，会提示输入 DeepSeek API key：

```powershell
irm https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.ps1 | iex
```

非交互式安装：

```powershell
$env:DEEPSEEK_API_KEY="<your-deepseek-api-key>"
irm https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.ps1 | iex
```

可选：同时安装 cc-switch：

```powershell
$env:INSTALL_CC_SWITCH="1"
irm https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.ps1 | iex
```

可选：非交互式安装并同时安装 cc-switch：

```powershell
$env:DEEPSEEK_API_KEY="<your-deepseek-api-key>"
$env:INSTALL_CC_SWITCH="1"
irm https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.ps1 | iex
```

可选：先不输入 API key，只安装 Claude Code 和 cc-switch，之后用 cc-switch 绑定 DeepSeek：

```powershell
$env:SKIP_DEEPSEEK_CONFIG="1"
$env:INSTALL_CC_SWITCH="1"
irm https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.ps1 | iex
```

如果 PowerShell 执行策略阻止脚本，可以改用 release 里的 `install.bat`，或者用管理员 PowerShell 临时允许当前进程执行脚本：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
irm https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.ps1 | iex
```

### 3. 验证 Claude Code

```powershell
claude --version
claude
```

## API 绑定说明

安装脚本会把下面这些环境配置写入 Claude Code 的 `settings.json`：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "<your-deepseek-api-key>",
    "ANTHROPIC_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-flash"
  }
}
```

你可以手动检查配置：

Linux/macOS:

```bash
cat ~/.claude/settings.json
```

Windows PowerShell:

```powershell
Get-Content "$HOME\.claude\settings.json"
```

## 切换模型

默认模型是 `deepseek-v4-flash`。安装完成后，不用 cc-switch 也可以切换模型。

Linux/macOS:

```bash
claude-deepseek flash
claude-deepseek pro
```

如果终端找不到 `claude-deepseek`，直接运行完整路径：

```bash
~/.local/bin/claude-deepseek flash
~/.local/bin/claude-deepseek pro
```

Windows:

```powershell
claude-deepseek flash
claude-deepseek pro
```

如果提示 `claude-deepseek` 无法识别，先重新打开 PowerShell 或 CMD。如果仍然不行，使用完整路径：

```powershell
& "$HOME\.claude-deepseek\claude-deepseek.cmd" flash
& "$HOME\.claude-deepseek\claude-deepseek.cmd" pro
```

切换后重新运行：

```bash
claude
```

也可以在安装时直接指定模型：

Linux:

```bash
curl -fsSL https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.sh | DEEPSEEK_MODEL="deepseek-v4-pro" bash
```

Windows:

```powershell
$env:DEEPSEEK_MODEL="deepseek-v4-pro"
irm https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.ps1 | iex
```

DeepSeek Anthropic-compatible API 当前常用模型名：

- `deepseek-v4-flash`
- `deepseek-v4-pro`

## 不使用 cc-switch

这是推荐方式。如果你只想用 Claude Code + DeepSeek，不想装 cc-switch，直接运行默认安装命令即可：

Linux/macOS:

```bash
curl -fsSL https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.sh | bash
```

Windows:

```powershell
irm https://github.com/BH4ME/claude-code-deepseek-installer/releases/latest/download/install.ps1 | iex
```

安装时输入 DeepSeek API key。之后：

```bash
claude
```

需要切换模型时，使用上面的 `claude-deepseek flash` 或 `claude-deepseek pro`。这个方式不依赖 cc-switch。

## 使用 cc-switch

cc-switch 是一个图形界面工具，可以用来管理 Claude Code、Codex、Gemini 等工具的 provider 配置。

这个项目里的 cc-switch 安装是可选的，因为很多 Linux 服务器没有桌面环境。如果你需要图形界面管理 provider，请使用上面的 `--with-cc-switch` 或 `INSTALL_CC_SWITCH=1`。

如果你不想在部署脚本里输入 API key，可以使用 `SKIP_DEEPSEEK_CONFIG=1`。这种模式只安装 Claude Code 和可选的 cc-switch，不会写入 DeepSeek token。之后你再打开 cc-switch 手动绑定 DeepSeek。

### Linux

安装脚本会下载最新版 cc-switch AppImage，并保存为：

```bash
~/.local/bin/cc-switch
```

运行：

```bash
~/.local/bin/cc-switch
```

如果你已经把 `~/.local/bin` 加入 PATH，也可以直接运行：

```bash
cc-switch
```

### Windows

安装脚本会下载最新版 cc-switch Windows MSI，并启动安装器。安装完成后，可以从开始菜单打开 `CC Switch`。

### 在 cc-switch 里绑定 DeepSeek

如果你想在 cc-switch 图形界面里手动检查或重新绑定：

1. 打开 `CC Switch`。
2. 找到 Claude Code provider 配置。
3. 设置 API base URL：

```text
https://api.deepseek.com/anthropic
```

4. 设置 API key 为你的 DeepSeek API key。
5. 设置模型名：

```text
deepseek-v4-flash
```

6. 应用配置后，重新打开终端运行：

```bash
claude
```

注意：不要在 cc-switch 里选择不受 DeepSeek Anthropic-compatible API 支持的模型名，例如旧的 `DeepSeek-V3.2`，否则 Claude Code 可能会报 `API Error: 400`。

## 常见问题

### `claude` 命令找不到

确认 npm 全局命令目录已经在 PATH 里：

```bash
npm bin -g
```

然后重新打开终端。Windows 用户安装 Node.js 后也建议重新打开 PowerShell。

### `API Error: 400` 或模型名不支持

检查 `settings.json` 里的模型名，确保是：

```text
deepseek-v4-flash
```

或者：

```text
deepseek-v4-pro
```

### 401 或认证失败

通常是 API key 不正确、失效、额度不足，或者复制时多了空格。重新运行安装脚本并输入新的 API key。

### 如何重新绑定 API key

直接重新运行安装命令即可。脚本会覆盖 DeepSeek 相关字段，并保留其他配置项。

## 安全提醒

- 不要把真实 API key 提交到 GitHub。
- 不要把真实 API key 写进 shell history、公开文档或截图。
- 如果 key 曾经出现在终端输出、issue、聊天截图或公开仓库里，建议立刻到 DeepSeek 控制台轮换。
