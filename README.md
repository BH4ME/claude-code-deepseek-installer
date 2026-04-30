# Claude Code DeepSeek Installer

一键安装 Claude Code，并把 Claude Code 配置为使用 DeepSeek 的 Anthropic-compatible API。

这个仓库不会保存、提交或发布任何 API key。安装时需要你在自己的电脑或服务器上输入 DeepSeek API key，或者通过环境变量临时传入。

## 功能

- 安装或更新 `@anthropic-ai/claude-code`
- 写入 Claude Code 配置文件：
  - Linux/macOS: `~/.claude/settings.json`
  - Windows: `%USERPROFILE%\.claude\settings.json`
- 默认绑定 DeepSeek：
  - API 地址：`https://api.deepseek.com/anthropic`
  - 模型：`deepseek-v4-flash`
- 保留已有 `settings.json` 里的其他配置项

## 准备 DeepSeek API Key

1. 打开 DeepSeek 控制台。
2. 创建或复制你的 API key。
3. 不要把 API key 写进 README、截图、GitHub issue、release notes 或公开脚本。
4. 安装时按提示粘贴 API key，或用 `DEEPSEEK_API_KEY` 环境变量传入。

## Linux 部署

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

### 3. 验证 Claude Code

```bash
claude --version
claude
```

进入 Claude Code 后可以测试：

```text
你当前使用的是什么模型？
```

## Windows 部署

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

默认模型是 `deepseek-v4-flash`。如果你想改成 `deepseek-v4-pro`，可以在安装时传入：

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

