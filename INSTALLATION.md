# Pi Sandbox — Agent Installation Guide

Follow these steps in order. Run each bash block exactly as written. Do not skip verification steps.

---

## 1. Check Prerequisites

```bash
git --version
```
Git must be available. If not, stop and install git first.

```bash
node --version
```
Node.js 18+ is required for `npm link`. If not available, the manual install path (step 3b) still works without it.

---

## 2. Clone the Repository

```bash
git clone https://github.com/hheydaroff/pi-sandbox.git ~/pi-sandbox
```

Verify:
```bash
ls ~/pi-sandbox/pi-sandbox ~/pi-sandbox/.devcontainer/Dockerfile ~/pi-sandbox/.devcontainer/ralph.sh
```
All three files must exist before continuing.

---

## 3. Install

```bash
cd ~/pi-sandbox && ./install.sh
```

This creates a symlink: `~/.local/bin/pi-sandbox` → `~/pi-sandbox/pi-sandbox`

---

## 4. Add `~/.local/bin` to PATH

Check if it is already in PATH:
```bash
echo $PATH | grep -q "$HOME/.local/bin" && echo "already in PATH" || echo "not in PATH"
```

If **not in PATH**, detect the active shell and add it:
```bash
# zsh
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
  grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc 2>/dev/null || \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi

# bash
if [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ] || [ "$SHELL" = "/usr/bin/bash" ]; then
  grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null || \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

export PATH="$HOME/.local/bin:$PATH"
```

---

## 5. Seed Configuration

`pi-sandbox` prompts interactively on first run if no config exists. Seed it directly to avoid prompts.

Choose one block based on the intended auth method:

**AWS Bedrock:**
```bash
mkdir -p ~/.config/pi-sandbox
cat > ~/.config/pi-sandbox/config << 'EOF'
PI_PROVIDER=bedrock
AWS_REGION=eu-central-1
DOCKER_ENABLED=true
EOF
```

Replace `eu-central-1` with the appropriate region:
- `us-east-1` — US East (N. Virginia)
- `us-west-2` — US West (Oregon)
- `eu-central-1` — Europe (Frankfurt)
- `eu-west-1` — Europe (Ireland)
- `ap-northeast-1` — Asia Pacific (Tokyo)

**Anthropic API key:**
```bash
mkdir -p ~/.config/pi-sandbox
cat > ~/.config/pi-sandbox/config << 'EOF'
PI_PROVIDER=anthropic
AWS_REGION=us-east-1
DOCKER_ENABLED=true
EOF
```

**OpenAI API key:**
```bash
mkdir -p ~/.config/pi-sandbox
cat > ~/.config/pi-sandbox/config << 'EOF'
PI_PROVIDER=openai
AWS_REGION=us-east-1
DOCKER_ENABLED=true
EOF
```

**Subscription (Claude Pro/Max, ChatGPT Plus):**
```bash
mkdir -p ~/.config/pi-sandbox
cat > ~/.config/pi-sandbox/config << 'EOF'
PI_PROVIDER=subscription
AWS_REGION=us-east-1
DOCKER_ENABLED=true
EOF
```

Set `DOCKER_ENABLED=false` if `/var/run/docker.sock` does not exist on the host:
```bash
[ -S /var/run/docker.sock ] && echo "DOCKER_ENABLED=true" || echo "DOCKER_ENABLED=false"
```

---

## 6. Verify Installation

```bash
pi-sandbox --help
```

Expected output starts with:
```
Initialize pi DevContainer sandbox in the current directory
```

If `pi-sandbox: command not found`, reload PATH:
```bash
export PATH="$HOME/.local/bin:$PATH"
pi-sandbox --help
```

---

## 7. Initialize a Project

Run in the target project directory (not in `~/pi-sandbox`):
```bash
cd /path/to/project
pi-sandbox
```

Because config was seeded in step 5, this runs without prompts and produces:
- `.devcontainer/devcontainer.json`
- `.devcontainer/Dockerfile`
- `.devcontainer/ralph.sh`
- `.pi-config/settings.json`

Verify:
```bash
ls .devcontainer/devcontainer.json .devcontainer/Dockerfile .devcontainer/ralph.sh .pi-config/settings.json
```

---

## 8. Open in VS Code DevContainer

```bash
code .
```

Then in VS Code: `Cmd+Shift+P` → **Dev Containers: Reopen in Container**

Or if the `devcontainer` CLI is available:
```bash
devcontainer open .
```

---

## Updating

```bash
cd ~/pi-sandbox && git pull
```

The symlink means no reinstall is needed. Re-run `pi-sandbox -f` in any existing project to regenerate `.devcontainer/` with the updated Dockerfile and scripts.
