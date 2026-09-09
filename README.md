# ⚡ Eleuther

**Eleuther** is a lightweight toolkit that connects your favorite terminal coding agents (**Claude Code**, **OpenAI Codex**, **OpenCode**, **Aider**) to hundreds of free models and intelligent failover routes via a local OmniRoute proxy, pre-configured with role personas and Caveman token optimization.

---

## 📜 Core Scripts

All core automation is organized into 4 simple scripts in `scripts/`:

| Script | Purpose |
| :--- | :--- |
| **`./scripts/install.sh`** | **Start here.** Installs OmniRoute, chosen coding agent, encryption secrets, free zero-key routes, skills, and shell configuration. |
| **`./scripts/register-keys.sh`** | Validates your `~/.omniroute/api-keys.env`, registers your API keys, and builds intelligent failover combos. |
| **`./scripts/backup.sh`** | **Safety first.** Interactively snapshots all OmniRoute settings, agent configurations, and full shell profiles to `~/.eleuther-backups/`. |
| **`./scripts/uninstall.sh`** | Granular cleanup tool: selectively removes agent variables, telemetry aliases, or restores from a previous backup. |

> *Detailed comments and options are documented inside each script file.*

---

## 🚀 Quick Start (In Order)

### 1. Run the Installer
```bash
git clone https://github.com/itzzsauravp/eleuther.git
cd eleuther
./scripts/install.sh
```
Follow the interactive prompts to pick your role and preferred terminal agent. The installer configures everything you need, including free zero-key model routes.

### 2. (Optional) Add Your API Keys
If you want to use paid or higher-tier models (Gemini, Groq, DeepSeek, Cerebras, OpenRouter, etc.):
```bash
nano ~/.omniroute/api-keys.env
```
Paste your API keys and save (`Ctrl+O`, `Enter`, `Ctrl+X`).

### 3. Register Keys & Build Combos
```bash
./scripts/register-keys.sh
```
This validates your keys, registers them with OmniRoute, and builds intelligent failover combos (`combo/execution`, `combo/architecture`, `combo/low-cost-batch`).

### 4. Reload Shell & Start Proxy
```bash
source ~/.bashrc   # or source ~/.zshrc
omniroute serve &
```

### 5. Launch Your Agent
Run your chosen agent CLI directly from your terminal:
- **Claude Code**: `claude`
- **Codex**: `codex`
- **OpenCode**: `opencode`
- **Aider**: `aider`

---

## 📊 Noise-Filtered Monitoring & Telemetry

Eleuther injects clean, noise-filtered monitoring aliases into your shell profile:

| Alias | Description |
| :--- | :--- |
| `or-serve` | Start the local OmniRoute proxy daemon |
| `or-combos` | List active failover routing combos |
| `or-status` | Check live connection status of model providers |
| `or-quota` | View provider token budgets & rate limits |
| `or-usage` | Show token usage analytics |
| `or-cost` | Show cost breakdown by provider & model |
| `or-telemetry` | View performance and latency telemetry |
| `or-logs` | Inspect real-time proxy request logs |
| `or-util` | Check compute utilization across tiers |
| `or-metrics` | Deep provider-level metrics |

---

## 🛡️ Robust Safety, Backup & Selective Uninstall

### Keep Backups of Your Settings
Before switching roles, upgrading agents, or modifying keys, snapshot your entire environment:
```bash
./scripts/backup.sh
```
- Backs up `~/.omniroute`, `~/.claude`, `~/.config/opencode`, workspace rules (`AGENTS.md`, `CONVENTIONS.md`, `.aider.conf.yml`), and full shell profiles (`.zshrc`, `.bashrc`, etc.).
- Preserves timestamped archives in: `~/.eleuther-backups/`
- Creates a `manifest.json` detailing all backed up files.

### Selective Uninstallation & Rollback
If you ever want to remove or selectively clean up configurations:
```bash
./scripts/uninstall.sh
```
- **Surgical Shell Cleaning**: Tagged blocks (`# <<< Eleuther: Agent ... <<<`) ensure you can remove Claude Code or Aider without touching your personal variables or telemetry aliases.
- **Rollback**: Offers 1-click restoration of previous configurations from `~/.eleuther-backups/latest`.

---

## 📝 License

MIT — Copyright (c) 2026 **Saurav Parajulee**.
