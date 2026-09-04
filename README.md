# 🚀 OmniRoute Free Token Maximizer

> **Maximize your free AI tokens by configuring OmniRoute with 50+ free providers and smart fallback combos.**

## What Is This?

This is a **shareable, open-source configuration** for [OmniRoute](https://omniroute.dev) — a unified AI router that sits between your coding tools (Claude Code, Codex, Cursor, etc.) and AI providers. 

The goal: **Get 1.5+ billion free tokens per month** by:

1. Connecting every free AI provider available
2. Setting up smart fallback combos (auto-switch when one provider's quota runs out)
3. Making it easy for anyone to replicate this setup

## 🎯 The Problem

Each free AI provider has limits:
- **Gemini**: 1500 requests/day
- **Groq**: 30 requests/minute  
- **NVIDIA**: 1000 credits
- **Cerebras**: Free tier with limits
- ...and so on

Individually, these aren't enough for heavy coding sessions. But **combined with smart routing**, you get massive token budgets.

## 💡 The Solution

OmniRoute's **combo system** with **auto-fallback**:

```
Request → aihorde (free) → if quota hit → groq (free) → if quota hit → gemini (free) → ...
```

Each provider is tried in order. When one runs out, the next takes over automatically.

## 📊 What's Included

### Pre-configured Combos

| Combo | Strategy | Description |
|-------|----------|-------------|
| `mega-free` | priority | All providers, auto-fallback |
| `free-fallback` | priority | Core free providers |
| `no-auth-only` | priority | Providers needing zero setup |
| `round-robin-free` | round-robin | Distribute load evenly |

### 50+ Free Providers

- **No-auth**: aihorde, opencode, huggingchat, firecrawl, searxng-search
- **Free API keys**: gemini, groq, nvidia, cerebras, sambanova, deepseek, mistral, cohere, huggingface, deepinfra, fireworks, nebius, siliconflow, hyperbolic, featherless, friendli, nscale, baseten, bytez, modelscope, pollinations, inference-net
- **Free pass-through routers**: openrouter, requesty, anyapi, freebuff, freeinference, free-ai, freetheai, dgrid, tokenreply, yolo-auto, zenmux, openadapter, api-airforce, bazaarlink, dahl, llm7, novita, bluesminds, freemodel-dev, freeaiapikey
- **Free Tier 2**: reka, ai21, nous, inception, scaleway, cloudflare-ai, modal, vertex, pioneer, morph

## 🚀 Quick Start

### 1. Install OmniRoute

```bash
npm install -g omniroute
```

### 2. Clone This Config

```bash
git clone https://github.com/yourusername/omniroute-config.git
cd omniroute-config
```

### 3. Run Setup

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### 4. Add Your API Keys

Edit `configs/api-keys.env` with your keys, then run:

```bash
chmod +x scripts/add-keys.sh
./scripts/add-keys.sh
```

### 5. Activate a Combo

```bash
omniroute combo switch mega-free
```

## 📁 Project Structure

```
omniroute-config/
├── README.md                    # This file
├── configs/
│   ├── api-keys.env.example    # Template for API keys
│   ├── combos.json             # Combo definitions
│   └── providers.json          # Provider configurations
├── scripts/
│   ├── setup.sh                # Automated setup
│   ├── add-keys.sh             # Add API keys from env file
│   ├── create-combos.sh        # Create all combos
│   └── test-combos.sh          # Test combo routing
└── docs/
    ├── API_KEYS_GUIDE.md       # Where to get each API key
    ├── COMBO_CUSTOMIZATION.md  # How to customize combos
    └── TROUBLESHOOTING.md      # Common issues and fixes
```

## 🔧 Customization

### Add a New Provider

```bash
# Add provider
omniroute providers add gemini --credential "YOUR_API_KEY" --yes

# Add to mega-free combo
omniroute combo delete mega-free
omniroute combo create mega-free priority \
  aihorde/any \
  opencode/auto \
  huggingchat/auto \
  ollama-cloud/auto \
  zcode/auto \
  gemini/auto \
  groq/auto \
  nvidia/auto
```

### Change Combo Strategy

```bash
# Round-robin instead of priority fallback
omniroute combo delete mega-free
omniroute combo create mega-free round-robin \
  aihorde/any groq/auto gemini/auto nvidia/auto
```

### Test a Combo

```bash
omniroute simulate "Write a Python function to sort a list" --combo mega-free --explain
```

## 📈 Expected Token Budget

With all free providers configured:

| Provider | Free Tier | Monthly Tokens (est.) |
|----------|-----------|----------------------|
| Gemini | 1500 req/day | ~45M tokens |
| Groq | 30 req/min | ~100M tokens |
| NVIDIA | 1000 credits | ~50M tokens |
| Cerebras | Free tier | ~30M tokens |
| SambaNova | Free tier | ~30M tokens |
| DeepSeek | Free tier | ~50M tokens |
| Mistral | Free tier | ~40M tokens |
| Cohere | Free tier | ~30M tokens |
| HuggingFace | Free tier | ~20M tokens |
| DeepInfra | Free tier | ~20M tokens |
| **No-auth providers** | Unlimited | ~100M tokens |
| **Pass-through routers** | Varies | ~50M tokens |
| **TOTAL** | | **~565M+ tokens** |

> **Note**: Actual token counts vary by usage patterns. With multiple providers and smart fallback, heavy users regularly hit 1B+ tokens/month.

## 🤝 Contributing

1. Fork this repo
2. Add new free providers or improve combos
3. Submit a PR with updates to `docs/API_KEYS_GUIDE.md`

## 📝 License

MIT — Use this freely. Share the free tokens love.

## ⚠️ Important Notes

- **Never commit real API keys** — use `api-keys.env` (gitignored)
- **Free tiers change** — check provider websites for current limits
- **Respect rate limits** — OmniRoute handles this automatically
- **Some providers need OAuth** — see `docs/API_KEYS_GUIDE.md` for details

## 🔗 Links

- [OmniRoute Documentation](https://omniroute.dev/docs)
- [OmniRoute GitHub](https://github.com/omniroute/omniroute)
- [Free AI Provider List](docs/API_KEYS_GUIDE.md)

---

**Made with ❤️ for the AI coding community**
