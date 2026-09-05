# ⚡ Eleuther

> **Universal Role & Terminal Agent Onboarding Engine**  
> Unlock **1.5+ billion free AI tokens/month**, role-tailored engineering personas, and universal **Caveman token optimization** across **Claude Code, OpenAI Codex, OpenCode, and Aider**.  
> Cross-platform: **macOS**, **Linux**, and **Windows (WSL / Git Bash)**.

---

## 🎖️ Acknowledgments & Project Origins

- **Core Routing Engine**: Eleuther is powered by the foundational **[OmniRoute](https://github.com/dreadnode/omniroute)** model orchestration engine. A huge shoutout to the OmniRoute team and contributors for creating an extraordinary local proxy for multi-provider AI model traffic.
- **Creator & Framework Architecture**: **Eleuther**—including its automated zero-risk safety backups, role-aware skill synthesizers, universal Caveman token optimizer protocol, terminal agent adapters (Claude Code, Codex, OpenCode, Aider), and cross-platform installation framework—was conceived and created by **[Saurav Parajulee](https://github.com/itzzsauravp)**.

---

## ⚡ Quick Start — The Only Script You Need

All you need to do is clone this repository and run the unified installer:

```bash
git clone https://github.com/itzzsauravp/omniroute-config.git eleuther
cd eleuther
./scripts/install.sh
```

**That's literally it.** The installer handles the rest automatically:
1. 🛡️ **Safety Backup**: Creates an isolated snapshot in `~/.omniroute-backups/latest/`.
2. 🎭 **Interactive Persona Selection**: Choose from 6 roles (Backend, Frontend, DevOps, Architect, QA, Designer).
3. 💻 **Terminal Agent Adapter**: Configures your choice of CLI agent (**Claude Code**, **Codex**, **OpenCode**, or **Aider**).
4. ⚡ **Universal Caveman Optimizer**: Injects high-density instructions to strip pleasantries, greetings, and filler words.
5. 🔑 **Automated Provider Registration**: Activates 7 zero-key free providers plus any keys in your `~/.omniroute/api-keys.env`.
6. 🔀 **Intelligent Routing Combos**: Compiles and validates smart failover tiers (`combo/execution`, `combo/architecture`, etc.).
7. 🐚 **Clean Shell Exports**: Injects environment variables and helpful aliases within clean, reversible managed blocks.

---

## 🛡️ Zero-Risk Safety & 1-Click Rollback

Before touching any configurations or shell profiles, Eleuther automatically snapshots your existing environment into `~/.omniroute-backups/latest/`.

If you ever wish to completely undo all changes:

```bash
./scripts/revert.sh
```

- Restores original `~/.omniroute`, `~/.claude`, `~/.config/opencode`, and workspace files (`AGENTS.md`, `CONVENTIONS.md`, `.aider.conf.yml`).
- Cleanly removes the `# <<< Eleuther Managed Block <<<` section from `~/.zshrc`, `~/.bashrc`, and `~/.bash_profile`.
- Zero orphan files left behind.

---

## 📜 Script Directory Guide — Keep It Simple

You don't need to juggle multiple scripts. Here is the concise catalog:

| Script | When to Use | Purpose |
| :--- | :--- | :--- |
| **`scripts/install.sh`** | 🌟 **Always Start Here** | **The unified installer.** Pre-install backup, role & terminal agent setup, provider registration, combo generation, and shell export. |
| **`scripts/revert.sh`** | When you want to rollback | **1-Click Undo.** Safely restores original files and cleans your shell profile. |
| **`scripts/add-keys.sh`** | After updating keys | Fast-syncs newly added keys from `~/.omniroute/api-keys.env` without a full re-install. |
| `scripts/backup.sh` | Internal | Automatically invoked by `install.sh` to snapshot configs before any changes. |
| `scripts/setup-skills.sh` | Internal | Compiles Caveman rules + role skills and injects them into the chosen terminal agent adapter. |
| `scripts/build-combos.sh` | Internal | Compiles and validates multi-tier intelligent routing combos. |

---

## 🎭 Role Personas & Terminal Agent Matrix

### 1. Terminal-Focused Coding Agents (`adapters/`)
Eleuther focuses on high-performance terminal CLI agents:
- **Claude Code**: Injects `.claude/commands/optimize.md` & `role-skills.md`, maps Sonnet/Opus models to free coding combos.
- **OpenAI Codex / CLI**: Generates workspace `AGENTS.md` and `.codex/instructions.md` with `OPENAI_BASE_URL` routing.
- **OpenCode CLI**: Injects rules into `.opencode/rules/omniroute-rules.md`.
- **Aider CLI**: Scaffolds `CONVENTIONS.md` and generates `.aider.conf.yml` pointing to the local proxy.

### 2. Universal Caveman Protocol (`skills/core/caveman.md`)
Applied across all roles and agents:
- Eliminates conversational fluff, pleasantries, and redundant sign-offs.
- Enforces direct diffs, executable one-liners, and dense bulleted technical notes.
- Maximizes token mileage on every provider tier.

### 3. Tailored Role Skills (`skills/roles/`)
- **DevOps**: Hardened Kubernetes manifests, Docker multi-stage builds, GitHub Actions pipelines, IaC safety guardrails.
- **Backend Dev**: Non-blocking DB migrations, OpenAPI 3.1 REST specs, SQL query indexing (`EXPLAIN ANALYZE`).
- **Frontend Dev**: Component architecture, Playwright E2E suites, DOM / Web Vitals optimization.
- **Designer**: Systematic design tokens (Tailwind / CSS), responsive Flex/Grid primitives, WCAG a11y contrast checks.
- **System Architect**: Domain-Driven Design (DDD) service boundaries, STRIDE threat modeling, multi-tier caching architectures.
- **QA**: Boundary value tests, automated fuzzing scenarios, regression and smoke test suites.

---

## 🔑 API Keys — Free Tokens Setup

All you need is your `~/.omniroute/api-keys.env` file. If it doesn't exist yet, `install.sh` automatically creates it from the template.

1. Edit your keys file:
   ```bash
   nano ~/.omniroute/api-keys.env
   # Or on Windows: notepad.exe "$HOME/.omniroute/api-keys.env"
   ```
2. Fill in the keys you have (leave missing ones blank — Eleuther automatically skips empty keys):
   - `GEMINI_API_KEY` (1,500 free requests/day)
   - `GROQ_API_KEY` (30 requests/min ultra-fast Llama 3.3)
   - `NVIDIA_API_KEY` (1,000 free requests/month Nemotron 340B)
   - `CEREBRAS_API_KEY` (Ultra-fast 70B inference)
   - `SAMBANOVA_API_KEY` (High-speed open models)
   - `DEEPSEEK_API_KEY` (Coding reasoning)
   - `OPENROUTER_API_KEY` (50+ free models)
3. Re-sync your keys at any time:
   ```bash
   ./scripts/add-keys.sh
   ```

---

## 💻 OS-Specific Quick Starts

### macOS
```bash
# 1. Install Node.js & git if missing
brew install node git

# 2. Clone & install
git clone https://github.com/itzzsauravp/omniroute-config.git eleuther
cd eleuther
./scripts/install.sh

# 3. Start proxy & reload shell
omniroute serve &
source ~/.zshrc

# 4. Launch your agent (e.g. Claude Code or Aider)
claude
```

### Linux (Ubuntu / Debian / Fedora / Arch)
```bash
# 1. Install Node.js & git if missing (Debian/Ubuntu)
sudo apt update && sudo apt install -y nodejs npm git

# 2. Clone & install
git clone https://github.com/itzzsauravp/omniroute-config.git eleuther
cd eleuther
./scripts/install.sh

# 3. Start proxy & reload shell
omniroute serve &
source ~/.bashrc

# 4. Launch your agent
claude
```

### Windows (WSL2 or Git Bash)
- **WSL2 (Recommended)**: Open Ubuntu in WSL2 and follow the Linux instructions above.
- **Native Git Bash**:
  1. Install [Node.js](https://nodejs.org/) and [Git for Windows](https://git-scm.com/) (includes Git Bash).
  2. Open Git Bash and run:
     ```bash
     git clone https://github.com/itzzsauravp/omniroute-config.git eleuther
     cd eleuther
     ./scripts/install.sh
     ```
  3. Start proxy: `omniroute serve &`
  4. Reload shell: `source ~/.bashrc`

---

## 🚀 Daily Workflow & Shell Aliases

```bash
# 1. Start the proxy server (run once per boot/session)
omniroute serve &

# 2. Handy management aliases added by installer
omni-stats     # View token usage and provider health
or-combos      # List configured routing combos
or-status      # View provider connection health
or-quota       # Check active rate limits and quotas

# 3. Switch combos on the fly
omniroute combo switch combo/execution         # Default: Balanced coding & speed
omniroute combo switch combo/architecture      # Deep reasoning & architectural design
omniroute combo switch combo/low-cost-batch    # Ultra-light quick edits

# 4. Launch your favorite terminal coding agent
claude         # Claude Code
codex          # OpenAI Codex / CLI
opencode       # OpenCode CLI
aider          # Aider CLI
```

---

## 📁 Repository Structure

```text
eleuther/
├── README.md                      # Complete documentation, credits & onboarding guide
├── LICENSE                        # MIT License
├── configs/
│   ├── api-keys.env.example       # API key template with recommended providers
│   ├── combos.json                # Combo definitions (execution, architecture, etc.)
│   └── providers.json             # Provider catalog metadata
├── scripts/
│   ├── install.sh                 # 🌟 One-click multi-agent onboarding installer
│   ├── revert.sh                  # 🛡️ 1-click rollback / revert script
│   ├── backup.sh                  # Pre-install automated backup engine
│   ├── setup-skills.sh            # Persona skill synthesizer & compiler
│   ├── add-keys.sh                # Provider API key registration tool
│   ├── build-combos.sh            # Routing combo generator & validator
│   └── backup-and-apply.sh        # Settings re-application helper
├── adapters/
│   ├── claude-code.sh             # Claude Code command & routing adapter
│   ├── codex.sh                   # Codex & CLI AGENTS.md adapter
│   ├── opencode.sh                # OpenCode rules adapter
│   └── aider.sh                   # Aider CONVENTIONS.md & config adapter
└── skills/
    ├── core/
    │   ├── caveman.md             # Universal token optimizer protocol
    │   ├── git-commits.md         # Conventional commit & diff standard
    │   └── security-linter.md     # Secret detection & secure coding standard
    └── roles/
        ├── devops.md              # Docker, K8s, CI/CD, IaC skills
        ├── backend.md             # DB migrations, OpenAPI, SQL indexing
        ├── frontend.md            # Component architecture, E2E, DOM profiling
        ├── designer.md            # Design tokens, CSS layout, a11y contrast
        ├── architect.md           # Microservices, threat modeling, caching
        └── qa.md                  # Boundary tests, fuzzing, regression suites
```

---

## 📝 License

MIT — Copyright (c) 2026 **Saurav Parajulee**.  
Powered by **OmniRoute**. _The best tokens are the free ones._
