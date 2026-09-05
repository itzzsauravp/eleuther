# 🚀 OmniRoute Free Token Maximizer

> **Get 1.5+ billion free AI tokens/month** — One-click install, zero cost, works on Windows / macOS / Linux.

---

## ⚡ TL;DR — One-Command Setup

```bash
# Linux / macOS / WSL / Git Bash
git clone https://github.com/itzzsauravp/omniroute-config.git
cd omniroute-config
./scripts/install.sh
```

That's it. The installer:

- ✅ Installs Node.js + OmniRoute
- ✅ Creates `~/.omniroute/` + encryption key (fixes `.env` warnings)
- ✅ Registers 7 no-auth providers (work instantly, zero keys)
- ✅ Reads your `~/.omniroute/api-keys.env` and registers every key found
- ✅ Builds 3 optimized routing combos (`combo/execution`, `combo/architecture`, `combo/low-cost-batch`)
- ✅ Activates `combo/execution` (priority: fast+smart → unlimited)
- ✅ Configures Claude Code environment variables in shell RC (`~/.zshrc` / `~/.bashrc`)
- ✅ Adds noise-filtered shell aliases (`or-combos`, `or-status`, `omni-stats`, etc.)

### 🔄 Updating with Existing Configuration Safely

If you already have OmniRoute configured and want to apply these optimized combos without losing your setup, run:

```bash
./scripts/backup-and-apply.sh
```

This will automatically backup your current configuration folder `~/.omniroute` to `~/.omniroute.bak` (plus a timestamped version), preserve all your custom settings and API keys, and then configure the new routing combos.

---

## 🎯 What You Get (3 Goals, Locked In)

| Goal                 | How It's Achieved                                                                                                                 |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| **Token Efficiency** | Limited quotas burned FIRST (Gemini 1,500/day → Groq 30/min → NVIDIA 1,000/mo), unlimited providers (AI Horde, OpenCode) are LAST |
| **Speed**            | Groq, Cerebras, SambaNova, Cloudflare ranked first — sub-second latency                                                           |
| **Accuracy**         | Strongest model at each tier: Nemotron 340B, DeepSeek R1, Gemini 2.0 Flash, Qwen 2.5 Coder                                        |

**The routing logic is deterministic:**

```
Request → Tier 1 (Fast Speed: Groq/Cerebras)
       → Tier 2 (Deep Code Logic: DeepSeek/Gemini/Mistral)
       → Tier 3 (High Allocation: SiliconFlow)
       → Tier 4 (Unlimited safety floor: OpenRouter/AI Horde)
```

---

## 📦 What's in the Box

| Script                         | Purpose                                                     |
| ------------------------------ | ----------------------------------------------------------- |
| `scripts/install.sh`           | **ONE-CLICK** — does everything automatically               |
| `scripts/add-keys.sh`          | Re-registers API keys from `~/.omniroute/api-keys.env`      |
| `scripts/build-combos.sh`      | Builds and validates all routing combos with simulation test |
| `scripts/backup-and-apply.sh`  | Backs up existing `~/.omniroute` and applies updated settings|
| `configs/api-keys.env.example` | Template — ✅ marks = keys author uses                      |
| `configs/combos.json`          | Combo configuration definitions                             |
| `configs/providers.json`       | Provider metadata and catalog definitions                   |

---

## 🪟 Platform-Specific Guide

### macOS (Terminal / iTerm2 / Warp)

```bash
# 1. Homebrew (recommended)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install node git

# 2. Clone + install
git clone https://github.com/itzzsauravp/omniroute-config.git
cd omniroute-config
./scripts/install.sh

# 3. Add keys
nano ~/.omniroute/api-keys.env
./scripts/add-keys.sh

# 4. Start server + load shell configuration (install.sh auto-configures ~/.zshrc)
omniroute serve &
source ~/.zshrc
```

**Tip:** For `or-*` aliases and Claude Code env variables to work immediately, `source ~/.zshrc` or open a new terminal window.

---

### Linux (Ubuntu / Debian / Fedora / Arch)

```bash
## I recommend using something like mise or nvm to install node

# Ubuntu/Debian
sudo apt update && sudo apt install -y nodejs npm git

# Fedora
sudo dnf install -y nodejs npm git

# Arch
sudo pacman -S nodejs npm git

# Then clone & install:
git clone https://github.com/itzzsauravp/omniroute-config.git
cd omniroute-config
./scripts/install.sh
nano ~/.omniroute/api-keys.env
./scripts/add-keys.sh
omniroute serve &
source ~/.bashrc
```

**Tip:** If `node` command is missing on Debian, ensure `nodejs` is symlinked or installed via NodeSource.

---

### Windows (PowerShell / Git Bash / WSL2)

#### Option A: WSL2 (RECOMMENDED — full Linux compatibility)

```powershell
# In PowerShell as Administrator
wsl --install
# Restart, then open "Ubuntu" from Start Menu
# Inside Ubuntu, run the Linux commands above
```

#### Option B: Git Bash (lightweight, native Windows)

```bash
# 1. Install Node.js: https://nodejs.org/ (LTS, 64-bit)
# 2. Install Git: https://git-scm.com/ (includes Git Bash)

# 3. Open Git Bash, run:
git clone https://github.com/itzzsauravp/omniroute-config.git
cd omniroute-config
./scripts/install.sh

# 4. Edit keys (use VS Code or Notepad)
code ~/.omniroute/api-keys.env
# or: notepad.exe "$HOME/.omniroute/api-keys.env"

# 5. Re-register keys
./scripts/add-keys.sh

# 6. Start server (keep this terminal open)
omniroute serve &

# 7. Reload shell in a new Git Bash terminal:
source ~/.bashrc
```

---

## 🔑 API Keys — What to Fill In

The template at `configs/api-keys.env.example` has **✅ marks** for keys the author actively uses.

| Key                  | Why                               | Get It                                          |
| -------------------- | --------------------------------- | ----------------------------------------------- |
| `GEMINI_API_KEY`     | 1,500/day Flash 2.0               | [AI Studio](https://aistudio.google.com/apikey) |
| `GROQ_API_KEY`       | 30/min Llama 3.3 70B              | [Groq Console](https://console.groq.com)        |
| `NVIDIA_API_KEY`     | 1,000/mo Nemotron 340B            | [NVIDIA Build](https://build.nvidia.com)        |
| `CEREBRAS_API_KEY`   | Fastest 70B                       | [Cerebras](https://cloud.cerebras.ai)           |
| `SAMBANOVA_API_KEY`  | Fast 70B                          | [SambaNova](https://cloud.sambanova.ai)         |
| `DEEPSEEK_API_KEY`   | Best free coder                   | [DeepSeek](https://platform.deepseek.com)       |
| `MISTRAL_API_KEY`    | Codestral + Large                 | [Mistral](https://console.mistral.ai)           |
| `OPENROUTER_API_KEY` | **50+ free models in one key** ⭐ | [OpenRouter](https://openrouter.ai)             |

> **No key = skipped automatically.** Only fill what you have.

---

## 🚀 Daily Workflow

```bash
# 1. Start server (do this once per session)
omniroute serve &

# 2. Use aliases (added to your shell by install.sh)
omni-stats     # token/provider health
or-quota       # quota usage
or-combos      # list configured combos
or-status      # provider connection status

# 3. Switch combos as needed
omniroute combo switch combo/execution         # default: max tokens + quality
omniroute combo switch combo/architecture      # architecture, debugging
omniroute combo switch combo/low-cost-batch    # quick edits

# 4. Test routing
omniroute simulate "Write a REST API in Go" --combo combo/execution --explain
```

---

## 🔧 Coding Tool Setup

### Claude Code

Add the following environment variables to your `~/.zshrc` or `~/.bashrc` (note: `install.sh` adds these automatically):

```bash
# ── OmniRoute + Claude Code ────────────────────────────────────
export ANTHROPIC_BASE_URL="http://localhost:20128/v1"
export ANTHROPIC_API_KEY="omni-route-key"
export ANTHROPIC_DEFAULT_SONNET_MODEL="auto/coding"
export ANTHROPIC_DEFAULT_OPUS_MODEL="auto/coding"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"
```

#### What each variable does:
- `ANTHROPIC_BASE_URL="http://localhost:20128/v1"`: Directs Claude Code traffic to OmniRoute's local endpoint on port 20128.
- `ANTHROPIC_API_KEY="omni-route-key"`: Acts as the local bearer token (OmniRoute intercepts and injects provider-specific keys upstream).
- `ANTHROPIC_DEFAULT_SONNET_MODEL="auto/coding"`: Maps Claude Sonnet calls directly to OmniRoute's active coding combo.
- `ANTHROPIC_DEFAULT_OPUS_MODEL="auto/coding"`: Maps Claude Opus calls directly to OmniRoute's active coding combo.
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"`: Disables non-essential telemetry calls to maximize token efficiency.

After editing or running `./scripts/install.sh`, reload your shell:

```bash
source ~/.zshrc    # or source ~/.bashrc
```

Then simply launch Claude Code:

```bash
claude
```

Claude Code will automatically route through your active OmniRoute combo.

---

## 📁 Project Structure

```
omniroute-config/
├── README.md                    # Documentation & setup guide
├── LICENSE                      # MIT — Saurav Parajulee
├── .gitignore                   # Protects api-keys.env
├── configs/
│   ├── api-keys.env.example     # Template (✅ = author's active keys)
│   ├── combos.json              # Combo definitions
│   └── providers.json           # Provider metadata
├── docs/
│   ├── API_KEYS_GUIDE.md        # Detailed guide to acquiring API keys
│   ├── COMBO_CUSTOMIZATION.md   # Combo architecture & routing strategies
│   └── TROUBLESHOOTING.md       # Troubleshooting & error resolution
└── scripts/
    ├── install.sh               # 🎯 ONE-CLICK installer
    ├── add-keys.sh              # Register API keys from ~/.omniroute/api-keys.env
    ├── build-combos.sh          # Builds and validates all routing combos
    └── backup-and-apply.sh      # Backs up existing ~/.omniroute and applies settings
```

---

## 📝 License

MIT — Copyright (c) 2026 **Saurav Parajulee**

## ❤️ Made with Love

**By Saurav Parajulee** — for the AI coding community.

> _The best tokens are the free ones._
