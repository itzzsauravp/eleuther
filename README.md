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
- ✅ Builds 3 optimized routing combos
- ✅ Activates `combo/execution` (priority: fast+smart → unlimited)
- ✅ Adds noise-filtered shell aliases (`or-combos`, `or-status`, etc.)

---

## 🎯 What You Get (3 Goals, Locked In)

| Goal | How It's Achieved |
|------|-------------------|
| **Token Efficiency** | Limited quotas burned FIRST (Gemini 1,500/day → Groq 30/min → NVIDIA 1,000/mo), unlimited providers (AI Horde, OpenCode) are LAST |
| **Speed** | Groq, Cerebras, SambaNova, Cloudflare ranked first — sub-second latency |
| **Accuracy** | Strongest model at each tier: Nemotron 340B, DeepSeek R1, Gemini 2.0 Flash, Qwen 2.5 Coder |

**The routing logic is deterministic:**
```
Request → Tier 1 (Fast Speed: Groq/Cerebras)
       → Tier 2 (Deep Code Logic: DeepSeek/Gemini/Mistral)
       → Tier 3 (High Allocation: SiliconFlow)
       → Tier 4 (Unlimited safety floor: OpenRouter/AI Horde)
```

---

## 📦 What's in the Box

| Script | Purpose |
|--------|---------|
| `scripts/install.sh` | **ONE-CLICK** — does everything above |
| `scripts/add-keys.sh` | Re-registers API keys from `~/.omniroute/api-keys.env` |
| `scripts/combo.sh` | Rebuilds all optimized combos (runs inside install) |
| `configs/api-keys.env.example` | Template — ✅ marks = keys author uses |

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

# 4. Start server + configure shell (zsh default on macOS)
omniroute serve &
echo 'export ANTHROPIC_BASE_URL=http://localhost:4000' >> ~/.zshrc
echo 'export ANTHROPIC_API_KEY=omniroute' >> ~/.zshrc
source ~/.zshrc
```

**Tip:** For `or-*` aliases to work immediately, `source ~/.zshrc` or open a new tab.

### Linux (Ubuntu / Debian / Fedora / Arch)

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y nodejs npm git

# Fedora
sudo dnf install -y nodejs npm git

# Arch
sudo pacman -S nodejs npm git

# Then same as macOS:
git clone https://github.com/itzzsauravp/omniroute-config.git
cd omniroute-config
./scripts/install.sh
nano ~/.omniroute/api-keys.env
./scripts/add-keys.sh
omniroute serve &
echo 'export ANTHROPIC_BASE_URL=http://localhost:4000' >> ~/.bashrc
echo 'export ANTHROPIC_API_KEY=omniroute' >> ~/.bashrc
source ~/.bashrc
```

**Tip:** If `node` command missing, try `nodejs`. Add `alias node=nodejs` to `.bashrc` if needed.

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

# 7. In a NEW Git Bash terminal, configure env vars:
export ANTHROPIC_BASE_URL=http://localhost:4000
export ANTHROPIC_API_KEY=omniroute
# Persist in Git Bash:
echo 'export ANTHROPIC_BASE_URL=http://localhost:4000' >> ~/.bashrc
echo 'export ANTHROPIC_API_KEY=omniroute' >> ~/.bashrc
source ~/.bashrc
```

---

## 🔑 API Keys — What to Fill In

The template at `configs/api-keys.env.example` has **✅ marks** for keys the author actively uses.

| Key | Why | Get It |
|-----|-----|--------|
| `GEMINI_API_KEY` | 1,500/day Flash 2.0 | [AI Studio](https://aistudio.google.com/apikey) |
| `GROQ_API_KEY` | 30/min Llama 3.3 70B | [Groq Console](https://console.groq.com) |
| `NVIDIA_API_KEY` | 1,000/mo Nemotron 340B | [NVIDIA Build](https://build.nvidia.com) |
| `CEREBRAS_API_KEY` | Fastest 70B | [Cerebras](https://cloud.cerebras.ai) |
| `SAMBANOVA_API_KEY` | Fast 70B | [SambaNova](https://cloud.sambanova.ai) |
| `DEEPSEEK_API_KEY` | Best free coder | [DeepSeek](https://platform.deepseek.com) |
| `MISTRAL_API_KEY` | Codestral + Large | [Mistral](https://console.mistral.ai) |
| `OPENROUTER_API_KEY` | **50+ free models in one key** ⭐ | [OpenRouter](https://openrouter.ai) |

> **No key = skipped automatically.** Only fill what you have.

---

## 🚀 Daily Workflow

```bash
# 1. Start server (do this once per session)
omniroute serve &

# 2. Use aliases (added to your shell by install.sh)
omni-stats     # token/provider health
or-quota       # quota usage

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
```bash
export ANTHROPIC_BASE_URL=http://localhost:4000
export ANTHROPIC_API_KEY=omniroute
# Add to ~/.zshrc or ~/.bashrc
```

---

## 📁 Project Structure

```
omniroute-config/
├── README.md                    # This file
├── LICENSE                      # MIT — Saurav Parajulee
├── .gitignore                   # Protects api-keys.env
├── configs/
│   ├── api-keys.env.example     # Template (✅ = author's active keys)
│   └── providers.json           # Provider metadata
└── scripts/
    ├── install.sh               # 🎯 ONE-CLICK installer
    ├── add-keys.sh              # Register API keys from ~/.omniroute/api-keys.env
    └── combo.sh                 # Builds all optimized combos
```

---

## 📝 License
MIT — Copyright (c) 2026 **Saurav Parajulee**

## ❤️ Made with Love
**By Saurav Parajulee** — for the AI coding community.
> *The best tokens are the free ones.*
