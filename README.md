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
- ✅ Builds 6 optimized routing combos
- ✅ Activates `mega-free` (36 models, priority: fast+smart → unlimited)
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
Request → Groq 70B (fastest, 30/min)
       → Gemini 2.0 Flash (smartest, 1,500/day)
       → Cerebras/SambaNova 70B (fast, generous)
       → Nemotron 340B (reasoning beast, 1,000/mo)
       → DeepSeek V3 / Mistral Large / Cohere R+
       → SiliconFlow / ModelScope / Pollinations / Cloudflare
       → OpenRouter free models (50+ models via one key)
       → AI Horde / OpenCode / HuggingChat (unlimited, never fails)
```

---

## 📦 What's in the Box

| Script | Purpose |
|--------|---------|
| `scripts/install.sh` | **ONE-CLICK** — does everything above |
| `scripts/add-keys.sh` | Re-registers API keys from `~/.omniroute/api-keys.env` |
| `scripts/combo.sh` | Rebuilds all 6 combos (runs inside install) |
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
omniroute serve

# 7. In a NEW Git Bash terminal, configure env vars:
export ANTHROPIC_BASE_URL=http://localhost:4000
export ANTHROPIC_API_KEY=omniroute
# Persist in Git Bash:
echo 'export ANTHROPIC_BASE_URL=http://localhost:4000' >> ~/.bashrc
echo 'export ANTHROPIC_API_KEY=omniroute' >> ~/.bashrc
source ~/.bashrc
```

#### Option C: PowerShell (native, no Git Bash)
```powershell
# 1. Install Node.js from https://nodejs.org/
# 2. Run in PowerShell:
git clone https://github.com/itzzsauravp/omniroute-config.git
cd omniroute-config

# 3. Run install via bash (Git Bash must be installed)
bash scripts/install.sh

# 4. Edit keys
notepad.exe "$env:USERPROFILE\.omniroute\api-keys.env"
bash scripts/add-keys.sh

# 5. Start server (keep running)
omniroute serve

# 6. In NEW PowerShell, set env vars for this session:
$env:ANTHROPIC_BASE_URL = "http://localhost:4000"
$env:ANTHROPIC_API_KEY = "omniroute"
# Persist permanently:
[Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://localhost:4000", "User")
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "omniroute", "User")
# Then restart terminal
```

---

## 🔑 API Keys — What to Fill In

The template at `configs/api-keys.env.example` has **✅ marks** for keys the author actively uses.

### Minimum for 1.5B tokens/month:
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

### Bonus (author also uses):
- `SILICONFLOW_API_KEY` — Qwen 72B
- `MODELSCOPE_API_KEY` — Chinese models
- `POLLINATIONS_API_KEY` — Open models
- `CLOUDFLARE_AI_API_KEY` — Workers AI
- `COHERE_API_KEY` — Command R+
- `HUGGINGFACE_API_KEY` — 1000+ open models
- `DEEPINFRA_API_KEY` — Cheap fallback

> **No key = skipped automatically.** Only fill what you have.

---

## 🚀 Daily Workflow

```bash
# 1. Start server (do this once per session)
omniroute serve &

# 2. Use aliases (added to your shell by install.sh)
or-combos      # list combos (no noise)
or-status      # provider health
or-quota       # quota usage
or-util        # utilization

# 3. Switch combos as needed
omniroute combo switch mega-free        # default: max tokens + quality
omniroute combo switch coding-focused   # best for code
omniroute combo switch heavy-reasoning  # architecture, debugging
omniroute combo switch fast-inference   # quick edits
omniroute combo switch free-fallback    # lean core
omniroute combo switch no-auth-only     # zero keys, works now
omniroute combo switch round-robin-free # spread load

# 4. Test routing
omniroute simulate "Write a REST API in Go" --combo mega-free --explain
```

---

## 🔧 Coding Tool Setup

### Claude Code
```bash
export ANTHROPIC_BASE_URL=http://localhost:4000
export ANTHROPIC_API_KEY=omniroute
# Add to ~/.zshrc or ~/.bashrc
```

### Cursor / Codex / Continue / Aider (OpenAI-compatible)
```bash
export OPENAI_BASE_URL=http://localhost:4000/v1
export OPENAI_API_KEY=omniroute
```

### Any HTTP Client
```bash
curl -X POST http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer omniroute" \
  -d '{"model": "mega-free", "messages": [{"role": "user", "content": "Hello"}]}'
```

---

## 📊 Estimated Monthly Budget (Full Setup)

| Provider | Free Tier | Est. Tokens/Month |
|----------|-----------|-------------------|
| Groq (30/min) | 43,200 req/day | ~100M |
| Gemini (1,500/day) | 45,000 req/mo | ~45M |
| NVIDIA (1,000/mo) | Nemotron 340B | ~50M |
| Cerebras/SambaNova | Generous | ~60M |
| DeepSeek | V3/Coder/R1 | ~50M |
| Mistral | Large/Codestral | ~40M |
| Cohere | Command R+ | ~30M |
| OpenRouter free | 50+ models | ~100M |
| SiliconFlow/ModelScope/Pollinations/Cloudflare | Various | ~100M |
| **AI Horde / OpenCode / HuggingChat** | **Unlimited** | **∞** |

**Total: 500M–1.5B+ tokens/month** depending on usage patterns.

---

## 🛠️ Advanced

### Rebuild combos after adding keys
```bash
./scripts/combo.sh --switch
```

### See which provider handles a request
```bash
omniroute simulate "Your prompt" --combo mega-free --explain
```

### Provider health
```bash
or-status
# or full:
omniroute providers status
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
│   ├── combos.json              # Legacy JSON (use scripts/combo.sh)
│   └── providers.json           # Provider metadata
└── scripts/
    ├── install.sh               # 🎯 ONE-CLICK installer
    ├── add-keys.sh              # Register API keys from ~/.omniroute/api-keys.env
    └── combo.sh                 # Builds all 6 optimized combos
```

---

## ⚠️ Important Notes

- **Never commit `api-keys.env`** — it's in `.gitignore`
- **Run `omniroute serve` BEFORE using Claude Code** — the server IS the router
- **Free tiers change** — check provider sites quarterly
- **NVIDIA / Cerebras / SambaNova may require credit card** for verification (still free)
- **Windows users:** WSL2 is strongly recommended for best compatibility

---

## 🤝 Contributing

1. Fork → add providers / improve combos
2. Update `configs/api-keys.env.example` with new key names
3. PR welcome!

---

## 📝 License

MIT — Copyright (c) 2026 **Saurav Parajulee**

---

## ❤️ Made with Love

**By Saurav Parajulee** — for the AI coding community.

> *The best tokens are the free ones.*

---

### Quick Commands Reference

```bash
# Install / Update
./scripts/install.sh          # full install (run once)
./scripts/add-keys.sh         # re-register keys after editing api-keys.env
./scripts/combo.sh --switch   # rebuild combos + activate mega-free

# Server
omniroute serve               # start (keep running)
omniroute serve --port 4000   # custom port

# Combos
omniroute combo list
omniroute combo switch mega-free
omniroute combo switch coding-focused

# Monitoring
or-combos | or-status | or-quota | or-util
omniroute simulate "prompt" --combo mega-free --explain

# Env for Claude Code
export ANTHROPIC_BASE_URL=http://localhost:4000
export ANTHROPIC_API_KEY=omniroute
```