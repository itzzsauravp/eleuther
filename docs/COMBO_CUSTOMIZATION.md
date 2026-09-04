# 🎛️ Combo Customization Guide

> **How to create, modify, and optimize your routing combos.**

## 📋 Table of Contents

- [Understanding Combos](#understanding-combos)
- [Routing Strategies](#routing-strategies)
- [Creating Custom Combos](#creating-custom-combos)
- [Modifying Existing Combos](#modifying-existing-combos)
- [Optimization Tips](#optimization-tips)
- [Advanced Configurations](#advanced-configurations)

---

## Understanding Combos

A **combo** is a list of providers and models that OmniRoute tries in order. When a request comes in:

1. OmniRoute tries the first provider/model
2. If it fails (rate limit, quota, error), it moves to the next
3. This continues until a provider succeeds or all are exhausted

### Combo Structure

```
combo-name
├── strategy: priority (or round-robin, weighted, etc.)
├── models:
│   ├── 1. provider-a/model-1
│   ├── 2. provider-b/model-2
│   └── 3. provider-c/model-3
└── enabled: true/false
```

---

## Routing Strategies

### 1. Priority (Default)

**Best for**: Maximizing uptime with fallback

```bash
omniroute combo create my-combo --strategy priority \
  --model "provider-a/model-1" \
  --model "provider-b/model-2" \
  --model "provider-c/model-3"
```

**Behavior**:
- Tries providers in order (1 → 2 → 3)
- Stops at first success
- Best for: ensuring requests always complete

---

### 2. Round-Robin

**Best for**: Distributing load evenly

```bash
omniroute combo create my-combo --strategy round-robin \
  --model "provider-a/model-1" \
  --model "provider-b/model-2" \
  --model "provider-c/model-3"
```

**Behavior**:
- Cycles through providers (1 → 2 → 3 → 1 → 2 → 3...)
- Each request goes to next provider
- Best for: avoiding rate limits on any single provider

---

### 3. Weighted

**Best for**: Prioritizing certain providers

```bash
omniroute combo create my-combo --strategy weighted \
  --model "provider-a/model-1" \
  --model "provider-b/model-2" \
  --model "provider-c/model-3"
```

**Behavior**:
- Routes based on weights (higher weight = more traffic)
- Best for: favoring faster/cheaper providers

---

### 4. Least-Used

**Best for**: Balancing across providers

```bash
omniroute combo create my-combo --strategy least-used \
  --model "provider-a/model-1" \
  --model "provider-b/model-2" \
  --model "provider-c/model-3"
```

**Behavior**:
- Routes to provider with least usage
- Best for: even distribution

---

### 5. Cost-Optimized

**Best for**: Minimizing costs

```bash
omniroute combo create my-combo --strategy cost-optimized \
  --model "provider-a/model-1" \
  --model "provider-b/model-2" \
  --model "provider-c/model-3"
```

**Behavior**:
- Routes to cheapest available provider
- Best for: paid providers with different pricing

---

### 6. Auto

**Best for**: Letting OmniRoute decide

```bash
omniroute combo create my-combo --strategy auto \
  --model "provider-a/model-1" \
  --model "provider-b/model-2" \
  --model "provider-c/model-3"
```

**Behavior**:
- Uses AI to select best provider based on task
- Best for: optimal performance without manual tuning

---

## Creating Custom Combos

### Basic Example

```bash
# Create a combo with priority fallback
omniroute combo create my-custom-combo --strategy priority \
  --model "aihorde/any" \
  --model "gemini/gemini-2.0-flash" \
  --model "groq/llama-3.3-70b-versatile" \
  --model "nvidia/llama-3.1-70b-instruct"
```

### Advanced Example

```bash
# Create a round-robin combo for code generation
omniroute combo create code-round-robin --strategy round-robin \
  --model "deepseek/deepseek-coder" \
  --model "mistral/codestral-latest" \
  --model "groq/llama-3.3-70b-versatile"
```

### With JSON

```bash
# Create combo from JSON file
cat > my-combo.json << 'EOF'
{
  "name": "my-combo",
  "strategy": "priority",
  "models": [
    {"provider": "aihorde", "model": "any"},
    {"provider": "gemini", "model": "gemini-2.0-flash"},
    {"provider": "groq", "model": "llama-3.3-70b-versatile"}
  ]
}
EOF

omniroute combo create my-combo --file my-combo.json
```

---

## Modifying Existing Combos

### Delete and Recreate

```bash
# Delete existing combo
omniroute combo delete my-combo

# Create new version
omniroute combo create my-combo --strategy priority \
  --model "aihorde/any" \
  --model "gemini/auto" \
  --model "new-provider/auto"
```

### Add Provider to Combo

```bash
# Current combo has: aihorde, gemini
# Want to add: groq

# 1. Delete old combo
omniroute combo delete my-combo

# 2. Create new with added provider
omniroute combo create my-combo --strategy priority \
  --model "aihorde/any" \
  --model "gemini/auto" \
  --model "groq/auto"  # Added
```

### Remove Provider from Combo

```bash
# Current combo has: aihorde, gemini, groq
# Want to remove: groq

# 1. Delete old combo
omniroute combo delete my-combo

# 2. Create new without groq
omniroute combo create my-combo --strategy priority \
  --model "aihorde/any" \
  --model "gemini/auto"
  # groq removed
```

### Change Strategy

```bash
# Current: priority
# Want: round-robin

omniroute combo delete my-combo
omniroute combo create my-combo --strategy round-robin \
  --model "aihorde/any" \
  --model "gemini/auto" \
  --model "groq/auto"
```

---

## Optimization Tips

### 1. Order Matters (Priority Strategy)

Put your best providers first:

```bash
# Good: Fast, free provider first
omniroute combo create optimized --strategy priority \
  --model "cerebras/llama3.1-8b" \      # Fastest
  --model "groq/llama-3.1-8b-instant" \ # Fast
  --model "gemini/gemini-2.0-flash" \    # Good
  --model "aihorde/any"                  # Fallback
```

### 2. Use Specific Models

Instead of `auto`, specify exact models:

```bash
# Better: specific model
--model "groq/llama-3.3-70b-versatile"

# Worse: auto (less predictable)
--model "groq/auto"
```

### 3. Group by Use Case

Create different combos for different tasks:

```bash
# Coding combo
omniroute combo create coding --strategy priority \
  --model "deepseek/deepseek-coder" \
  --model "mistral/codestral-latest" \
  --model "groq/llama-3.3-70b-versatile"

# Chat combo
omniroute combo create chat --strategy round-robin \
  --model "gemini/gemini-2.0-flash" \
  --model "groq/llama-3.3-70b-versatile" \
  --model "nvidia/llama-3.1-70b-instruct"

# Reasoning combo
omniroute combo create reasoning --strategy priority \
  --model "deepseek/deepseek-reasoner" \
  --model "nvidia/llama-3.1-405b-instruct" \
  --model "gemini/gemini-1.5-pro"
```

### 4. Monitor Performance

```bash
# Test combo routing
omniroute simulate "Your prompt" --combo my-combo --explain

# Check provider status
omniroute providers status

# View cost report
omniroute cost
```

### 5. Use Fallback Chains

Always have a fallback:

```bash
# Primary → Secondary → Fallback
omniroute combo create reliable --strategy priority \
  --model "gemini/gemini-2.0-flash" \      # Primary
  --model "groq/llama-3.3-70b-versatile" \ # Secondary
  --model "aihorde/any"                     # Ultimate fallback
```

---

## Advanced Configurations

### 1. Model-Specific Combos

```bash
# Best for code generation
omniroute combo create code-best --strategy priority \
  --model "deepseek/deepseek-coder" \
  --model "mistral/codestral-latest" \
  --model "codestral/codestral-latest"

# Best for reasoning
omniroute combo create reasoning-best --strategy priority \
  --model "deepseek/deepseek-reasoner" \
  --model "nvidia/llama-3.1-405b-instruct" \
  --model "gemini/gemini-1.5-pro"

# Best for speed
omniroute combo create speed-best --strategy priority \
  --model "cerebras/llama3.1-8b" \
  --model "groq/llama-3.1-8b-instant" \
  --model "sambanova/llama-3.1-8b"
```

### 2. Cost-Optimized Combos

```bash
# Free first, then paid
omniroute combo create cost-optimized --strategy priority \
  --model "aihorde/any" \                    # Free
  --model "opencode/auto" \                  # Free
  --model "huggingchat/auto" \               # Free
  --model "gemini/gemini-2.0-flash" \        # Free tier
  --model "groq/llama-3.3-70b-versatile" \   # Free tier
  --model "deepseek/deepseek-chat"           # Cheap paid
```

### 3. Multi-Region Combos

```bash
# Different providers for different regions
omniroute combo create global --strategy round-robin \
  --model "gemini/gemini-2.0-flash" \        # Global
  --model "siliconflow/Qwen/Qwen2.5-7B-Instruct" \  # Asia
  --model "deepseek/deepseek-chat" \         # Asia
  --model "groq/llama-3.3-70b-versatile" \   # US
  --model "nvidia/llama-3.1-70b-instruct"    # US
```

### 4. Task-Specific Combos

```bash
# Writing tasks
omniroute combo create writing --strategy priority \
  --model "gemini/gemini-1.5-pro" \
  --model "cohere/command-r-plus" \
  --model "mistral/mistral-large-latest"

# Analysis tasks
omniroute combo create analysis --strategy priority \
  --model "deepseek/deepseek-reasoner" \
  --model "nvidia/llama-3.1-405b-instruct" \
  --model "gemini/gemini-1.5-pro"

# Quick tasks
omniroute combo create quick --strategy priority \
  --model "cerebras/llama3.1-8b" \
  --model "groq/llama-3.1-8b-instant" \
  --model "aihorde/any"
```

---

## 📊 Combo Templates

### Template 1: Maximum Free Tokens

```bash
omniroute combo create max-free --strategy priority \
  --model "aihorde/any" \
  --model "opencode/auto" \
  --model "huggingchat/auto" \
  --model "ollama-cloud/auto" \
  --model "zcode/auto" \
  --model "firecrawl/auto" \
  --model "searxng-search/auto" \
  --model "gemini/auto" \
  --model "groq/auto" \
  --model "nvidia/auto" \
  --model "cerebras/auto" \
  --model "sambanova/auto" \
  --model "deepseek/auto" \
  --model "mistral/auto" \
  --model "cohere/auto" \
  --model "huggingface/auto" \
  --model "deepinfra/auto" \
  --model "fireworks/auto" \
  --model "nebius/auto" \
  --model "siliconflow/auto" \
  --model "hyperbolic/auto" \
  --model "featherless/auto" \
  --model "friendli/auto" \
  --model "nscale/auto" \
  --model "baseten/auto" \
  --model "bytez/auto" \
  --model "modelscope/auto" \
  --model "pollinations/auto" \
  --model "inference-net/auto" \
  --model "openrouter/auto" \
  --model "requesty/auto" \
  --model "anyapi/auto" \
  --model "freebuff/auto" \
  --model "freeinference/auto" \
  --model "free-ai/auto" \
  --model "freetheai/auto" \
  --model "dgrid/auto" \
  --model "tokenreply/auto" \
  --model "yolo-auto/auto" \
  --model "zenmux/auto" \
  --model "openadapter/auto" \
  --model "api-airforce/auto" \
  --model "bazaarlink/auto" \
  --model "dahl/auto" \
  --model "llm7/auto" \
  --model "novita/auto" \
  --model "bluesminds/auto" \
  --model "freemodel-dev/auto" \
  --model "freeaiapikey/auto"
```

### Template 2: Balanced Performance

```bash
omniroute combo create balanced --strategy priority \
  --model "gemini/gemini-2.0-flash" \
  --model "groq/llama-3.3-70b-versatile" \
  --model "nvidia/llama-3.1-70b-instruct" \
  --model "cerebras/llama3.1-70b" \
  --model "sambanova/llama-3.1-70b" \
  --model "deepseek/deepseek-chat" \
  --model "mistral/mistral-7b-instruct" \
  --model "cohere/command-r" \
  --model "aihorde/any"
```

### Template 3: Speed Priority

```bash
omniroute combo create speed --strategy priority \
  --model "cerebras/llama3.1-8b" \
  --model "groq/llama-3.1-8b-instant" \
  --model "sambanova/llama-3.1-8b" \
  --model "nvidia/llama-3.1-8b-instruct" \
  --model "deepinfra/meta-llama/Meta-Llama-3.1-8B-Instruct" \
  --model "aihorde/any"
```

---

## 🔧 Troubleshooting

### Combo Not Working

```bash
# Check combo exists
omniroute combo list

# Test combo routing
omniroute simulate "test" --combo my-combo --explain

# Check provider status
omniroute providers status
```

### Provider Not in Combo

```bash
# Check if provider is configured
omniroute providers list

# Add provider if missing
omniroute providers add provider-id --credential "key" --yes

# Recreate combo with provider
omniroute combo delete my-combo
omniroute combo create my-combo --strategy priority \
  --model "provider-id/auto" \
  --model "other-provider/auto"
```

### Strategy Not Working

```bash
# Check available strategies
omniroute combo create --help

# Recreate with correct strategy
omniroute combo delete my-combo
omniroute combo create my-combo --strategy correct-strategy \
  --model "provider-a/auto" \
  --model "provider-b/auto"
```

---

## 📚 Next Steps

- [API Keys Guide](API_KEYS_GUIDE.md) — Get API keys for providers
- [Troubleshooting](TROUBLESHOOTING.md) — Common issues and fixes
- [OmniRoute Docs](https://omniroute.dev/docs) — Official documentation

---

**Last updated**: 2026-09-04
