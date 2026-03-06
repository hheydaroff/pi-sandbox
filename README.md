# Pi Sandbox DevContainer

A ready-to-use VS Code DevContainer for running [pi](https://shittycodingagent.ai) in an isolated, sandboxed environment.

## Features

- **Isolated execution** — pi runs inside a container, can't touch your host filesystem
- **Config sync** — Automatically syncs your `AGENTS.md`, skills, prompts, extensions, themes, and custom models from `~/.pi/agent/`
- **Claude skills live link** — `~/.claude/skills` is bind-mounted read-only and wired into pi's `settings.json`; changes on the host are immediately visible inside the container
- **Multiple auth methods** — AWS Bedrock, Anthropic API key, OpenAI API key, or subscription login
- **Docker-in-Docker** — pi can run Docker commands (auto-detected)
- **GitHub CLI included** — Easy Git authentication with `gh auth login`
- **Autonomous loop** — `ralph.sh` runs pi in batch mode to work through task lists unattended
- **Saved preferences** — First-run prompts save to `~/.config/pi-sandbox/config`; subsequent runs use those defaults silently

## Quick Start

> **For agents:** See [INSTALLATION.md](INSTALLATION.md) for a step-by-step, non-interactive install guide written for autonomous execution.

### 1. Install

```bash
git clone https://github.com/hheydaroff/pi-sandbox.git ~/pi-sandbox
cd ~/pi-sandbox
./install.sh
```

Make sure `~/.local/bin` is in your `PATH` (add to `~/.zshrc` or `~/.bashrc` if needed):

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### 2. Initialize a project

```bash
cd /path/to/your/project
pi-sandbox
```

**First run** prompts for:
- **Authentication method**: AWS Bedrock, Anthropic API key, OpenAI API key, or subscription
- **AWS region** (Bedrock only)

Answers are saved to `~/.config/pi-sandbox/config`. Every subsequent run uses those defaults — no prompts.

### 3. Open in VS Code

1. Open the project folder in VS Code
2. `Cmd+Shift+P` → **Dev Containers: Reopen in Container**
3. Wait for the container to build (pi installs automatically on first build)

### 4. Authenticate and run pi

Inside the container terminal:

**AWS Bedrock:**
```bash
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
pi
```

**Anthropic API key:**
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
pi
```

**OpenAI API key:**
```bash
export OPENAI_API_KEY="sk-..."
pi
```

**Subscription (Claude Pro/Max, ChatGPT Plus, etc.):**
```bash
pi
/login   # then select your provider
```

## CLI Options

```
pi-sandbox [options]

Options:
  -f, --force        Overwrite existing .devcontainer
  -o, --open         Open in VS Code after setup
  -p, --provider     Auth provider: bedrock, anthropic, openai, subscription
  -r, --region       AWS region (for Bedrock): eu-central-1, us-east-1, etc.
  -m, --mount        Add extra mount path (can be used multiple times)
  --no-docker        Disable Docker socket mount
  --reconfigure      Re-run configuration prompts and re-save defaults
  -h, --help         Show help
```

### Examples

```bash
pi-sandbox                                    # use saved defaults
pi-sandbox --provider bedrock --region eu-central-1
pi-sandbox --provider anthropic               # override provider for this project
pi-sandbox --mount /path/to/shared/data       # add an extra mount
pi-sandbox -f                                 # overwrite existing .devcontainer
pi-sandbox --reconfigure                      # change saved defaults
```

## Saved Configuration

Preferences are stored in `~/.config/pi-sandbox/config`:

```bash
PI_PROVIDER=bedrock        # or anthropic, openai, subscription
AWS_REGION=eu-central-1   # Bedrock only
DOCKER_ENABLED=true        # auto-detected from /var/run/docker.sock at generation time
```

> **Tip:** If the region or Docker setting looks wrong (e.g. Docker wasn't running when you first ran `pi-sandbox`), edit this file directly or run `pi-sandbox --reconfigure`.

## What Gets Generated

```
your-project/
├── .devcontainer/
│   ├── devcontainer.json   # VS Code container config (mounts, env vars, postCreate)
│   ├── Dockerfile          # Ubuntu 22.04 + Node.js 20 + Docker CLI + GitHub CLI
│   └── ralph.sh            # Autonomous loop script
└── .pi-config/             # Synced once from ~/.pi/agent/ at generation time
    ├── settings.json       # Generated: provider, model, thinking level, skills path
    ├── models.json         # Custom provider/model definitions (e.g. LM Studio)
    ├── AGENTS.md           # Global context instructions (if present)
    ├── skills/             # Pi skills
    ├── prompts/            # Prompt templates
    ├── extensions/         # Extensions
    └── themes/             # Themes
```

## Config Sync

### Pi config (`~/.pi/agent/` → container)

Copied once into `.pi-config/` at generation time, then bind-mounted into the container:

| Host `~/.pi/agent/` | Container `~/.pi/agent/` | Purpose |
|---------------------|--------------------------|---------|
| `AGENTS.md`         | `AGENTS.md`              | Global context instructions |
| `CLAUDE.md`         | `CLAUDE.md`              | Alternate context file |
| `models.json`       | `models.json`            | Custom provider/model definitions |
| `skills/*`          | `skills/*`               | Pi skills |
| `prompts/*`         | `prompts/*`              | Prompt templates |
| `extensions/*`      | `extensions/*`           | Extensions |
| `themes/*`          | `themes/*`               | Themes |
| *(generated)*       | `settings.json`          | Provider, model, thinking level, skills path |

`auth.json` and `sessions/` are not synced. OAuth tokens are machine-bound; use `/login` inside the container for subscription auth.

To pick up changes from `~/.pi/agent/`, re-run `pi-sandbox -f` to regenerate `.pi-config/`.

### Claude skills (`~/.claude/skills` → container)

If `~/.claude/skills` exists on your host, it is **bind-mounted directly** into the container at `~/.claude/skills` (read-only) and added to pi's `settings.json`:

```json
"skills": ["~/.claude/skills"]
```

This is a **live link** — any skill you add or edit on the host is immediately available inside the container without rebuilding. Pi loads them alongside its own skills and exposes each as a `/skill:name` command.

## Autonomous Loop (`ralph.sh`)

For unattended batch task execution, `ralph.sh` is available inside the container:

```bash
ralph.sh 20 tasks.json
ralph.sh 20 PRD.md
```

Create a task list file, then ralph runs pi in print mode repeatedly — one task per iteration — committing after each, until all tasks are marked complete or the iteration limit is reached.

## Git Authentication

```bash
# One-time setup inside the container
gh auth login
# GitHub.com → HTTPS → Login with a web browser

# Git commands then work normally
git push origin main
```

## Security Model

```
┌─────────────────────────────────────────┐
│  Your Host Machine                      │
│  ┌───────────────────────────────────┐  │
│  │  DevContainer (Isolated)          │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  pi                         │  │  │
│  │  │  (no permission popups)     │  │  │
│  │  └─────────────────────────────┘  │  │
│  │                                   │  │
│  │  Can access:                      │  │
│  │  ✅ /workspace (your project)     │  │
│  │  ✅ ~/.claude/skills (read-only)  │  │
│  │  ✅ Docker socket (if enabled)    │  │
│  │  ✅ Git config (read-only)        │  │
│  │  ✅ Extra mounts (if specified)   │  │
│  │                                   │  │
│  │  Cannot access:                   │  │
│  │  ❌ Rest of host filesystem       │  │
│  │  ❌ Host SSH keys / secrets       │  │
│  │  ❌ Host processes                │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) 4.x+ (must be running when you open the devcontainer)
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- One of:
  - AWS account with Bedrock access
  - Anthropic API key
  - OpenAI API key
  - Claude Pro/Max or ChatGPT Plus subscription

## Troubleshooting

### "pi-sandbox: not found"
`~/.local/bin` is not in your PATH. Add to `~/.zshrc` or `~/.bashrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Wrong region or Docker disabled
The saved config was written when Docker wasn't running or you picked the wrong region. Fix it:
```bash
# Edit directly
nano ~/.config/pi-sandbox/config

# Or re-run the interactive prompts
pi-sandbox --reconfigure
```

### Container won't start
Ensure Docker Desktop is running before opening the devcontainer:
```bash
open -a Docker   # macOS
```

### "pi: not found" inside the container
The `postCreateCommand` may have failed. Run manually:
```bash
npm config set prefix ~/.local
npm install -g @mariozechner/pi-coding-agent
export PATH="$HOME/.local/bin:$PATH"
```

### Authentication errors

**Bedrock:**
```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

**Anthropic:**
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

**Subscription:** Run `pi` then `/login`.

## Updating

```bash
cd ~/pi-sandbox && git pull
```

The symlink means updates to the script take effect immediately. Re-run `pi-sandbox -f` in any project to regenerate `.devcontainer/` with the latest Dockerfile and scripts.

## Uninstall

```bash
rm ~/.local/bin/pi-sandbox
rm -rf ~/pi-sandbox
rm -rf ~/.config/pi-sandbox
```

## License

MIT
