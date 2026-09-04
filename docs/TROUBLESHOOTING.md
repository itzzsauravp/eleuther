# 🔧 Troubleshooting Guide

> **Common issues and fixes when setting up OmniRoute with free providers.**

## 📋 Table of Contents

- [Installation Issues](#installation-issues)
- [Provider Issues](#provider-issues)
- [Combo Issues](#combo-issues)
- [API Key Issues](#api-key-issues)
- [Performance Issues](#performance-issues)
- [Error Messages](#error-messages)

---

## Installation Issues

### OmniRoute Not Found

**Error**:
```
omniroute: command not found
```

**Fix**:
```bash
# Install OmniRoute
npm install -g omniroute

# Or with yarn
yarn global add omniroute

# Or with pnpm
pnpm add -g omniroute

# Verify installation
omniroute --version
```

---

### Permission Denied

**Error**:
```
EACCES: permission denied
```

**Fix**:
```bash
# Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH

# Add to ~/.bashrc or ~/.zshrc
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# Reinstall
npm install -g omniroute
```

---

### Node Version Too Old

**Error**:
```
OmniRoute requires Node.js 18 or higher
```

**Fix**:
```bash
# Check Node version
node --version

# Update Node (using nvm)
nvm install 20
nvm use 20

# Or using mise
mise install node@20
```

---

## Provider Issues

### Provider Not Added

**Error**:
```
✖ Invalid provider
```

**Fix**:
```bash
# Check if provider exists
omniroute providers available | grep provider-name

# Check provider category
omniroute providers available --category api-key

# Add with correct syntax
omniroute providers add provider-id --credential "api-key" --yes
```

---

### Provider Already Exists

**Error**:
```
Provider already exists
```

**Fix**:
```bash
# Check existing providers
omniroute providers list

# Remove existing provider
omniroute providers remove provider-id

# Re-add provider
omniroute providers add provider-id --credential "api-key" --yes
```

---

### Provider Authentication Failed

**Error**:
```
Authentication failed
```

**Fix**:
```bash
# Verify API key is correct
# Check provider dashboard for correct key

# Test provider connection
omniroute providers test provider-id

# Re-add with correct key
omniroute providers remove provider-id
omniroute providers add provider-id --credential "correct-key" --yes
```

---

### Provider Rate Limited

**Error**:
```
Rate limit exceeded
```

**Fix**:
```bash
# Check provider status
omniroute providers status

# Wait for rate limit to reset
# Most free tiers reset in 1-60 minutes

# Add more providers to combo for fallback
omniroute combo delete my-combo
omniroute combo create my-combo --strategy priority \
  --model "provider-a/auto" \
  --model "provider-b/auto" \
  --model "provider-c/auto"
```

---

## Combo Issues

### Combo Not Found

**Error**:
```
No matching combo found
```

**Fix**:
```bash
# List available combos
omniroute combo list

# Create combo if missing
omniroute combo create my-combo --strategy priority \
  --model "provider-a/auto" \
  --model "provider-b/auto"

# Switch to combo
omniroute combo switch my-combo
```

---

### Combo Creation Failed

**Error**:
```
Failed to create combo
```

**Fix**:
```bash
# Check if providers exist
omniroute providers list

# Add missing providers
omniroute providers add provider-id --no-credential --yes

# Try creating combo again
omniroute combo create my-combo --strategy priority \
  --model "provider-a/auto"
```

---

### Combo Not Routing

**Error**:
```
No providers available
```

**Fix**:
```bash
# Check provider status
omniroute providers status

# Check combo configuration
omniroute combo list

# Test combo routing
omniroute simulate "test" --combo my-combo --explain

# Recreate combo with working providers
omniroute combo delete my-combo
omniroute combo create my-combo --strategy priority \
  --model "working-provider/auto"
```

---

### Wrong Strategy

**Error**:
```
Strategy not found
```

**Fix**:
```bash
# Check available strategies
omniroute combo create --help

# Valid strategies:
# - priority
# - weighted
# - round-robin
# - p2c
# - random
# - auto
# - lkgp
# - context-optimized
# - context-relay
# - fill-first
# - cost-optimized
# - least-used
# - strict-random
# - reset-aware

# Recreate with correct strategy
omniroute combo delete my-combo
omniroute combo create my-combo --strategy priority \
  --model "provider-a/auto"
```

---

## API Key Issues

### Invalid API Key

**Error**:
```
Invalid API key
```

**Fix**:
```bash
# Verify API key in provider dashboard
# Check for extra spaces or characters

# Re-add provider with correct key
omniroute providers remove provider-id
omniroute providers add provider-id --credential "correct-key" --yes
```

---

### API Key Not Working

**Error**:
```
Authentication failed
```

**Fix**:
```bash
# Check if API key is active in provider dashboard
# Verify API key has correct permissions

# Test provider connection
omniroute providers test provider-id

# Check provider status
omniroute providers status
```

---

### API Key Expired

**Error**:
```
API key expired
```

**Fix**:
```bash
# Generate new API key in provider dashboard
# Update OmniRoute with new key

omniroute providers remove provider-id
omniroute providers add provider-id --credential "new-key" --yes
```

---

### API Key Leaked

**Error**:
```
API key compromised
```

**Fix**:
```bash
# 1. Immediately revoke key in provider dashboard
# 2. Generate new API key
# 3. Update OmniRoute
omniroute providers remove provider-id
omniroute providers add provider-id --credential "new-key" --yes

# 4. Check .gitignore to prevent future leaks
echo "api-keys.env" >> .gitignore
```

---

## Performance Issues

### Slow Response Times

**Symptom**: Requests take too long

**Fix**:
```bash
# Use faster models
omniroute combo create fast --strategy priority \
  --model "cerebras/llama3.1-8b" \      # Fastest
  --model "groq/llama-3.1-8b-instant" \ # Fast
  --model "sambanova/llama-3.1-8b" \     # Fast
  --model "aihorde/any"                  # Fallback

# Test with simulate
omniroute simulate "test" --combo fast --explain
```

---

### High Token Usage

**Symptom**: Using too many tokens

**Fix**:
```bash
# Use smaller models
omniroute combo create efficient --strategy priority \
  --model "cerebras/llama3.1-8b" \      # 8B params
  --model "groq/llama-3.1-8b-instant" \ # 8B params
  --model "aihorde/any"                  # Fallback

# Monitor usage
omniroute cost
omniroute usage
```

---

### Provider Quota Exceeded

**Error**:
```
Quota exceeded
```

**Fix**:
```bash
# Check provider quota
omniroute providers status

# Add more providers to combo
omniroute combo delete my-combo
omniroute combo create my-combo --strategy priority \
  --model "provider-a/auto" \
  --model "provider-b/auto" \
  --model "provider-c/auto"

# Wait for quota reset
# Most free tiers reset daily or hourly
```

---

## Error Messages

### Connection Refused

**Error**:
```
Connection refused
```

**Fix**:
```bash
# Check if OmniRoute is running
omniroute doctor

# Start OmniRoute
omniroute serve

# Check port
ss -tlnp | grep 20128
```

---

### Timeout Error

**Error**:
```
Request timeout
```

**Fix**:
```bash
# Increase timeout
omniroute serve --timeout 60000

# Or set in environment
export OMNIROUTE_TIMEOUT=60000
```

---

### Database Error

**Error**:
```
SQLite error
```

**Fix**:
```bash
# Check database
omniroute doctor

# Backup database
cp ~/.omniroute/storage.sqlite ~/.omniroute/storage.sqlite.backup

# Reset database (WARNING: loses data)
rm ~/.omniroute/storage.sqlite
omniroute serve  # Recreates database
```

---

### Memory Error

**Error**:
```
JavaScript heap out of memory
```

**Fix**:
```bash
# Increase Node.js memory
export NODE_OPTIONS="--max-old-space-size=4096"

# Restart OmniRoute
omniroute restart
```

---

## 🆘 Getting Help

### Check OmniRoute Status

```bash
# Run doctor
omniroute doctor

# Check providers
omniroute providers list
omniroute providers status

# Check combos
omniroute combo list

# View logs
omniroute logs
```

### Reset Everything

```bash
# Stop OmniRoute
omniroute stop

# Backup config
cp -r ~/.omniroute ~/.omniroute-backup-$(date +%Y%m%d)

# Reset database
rm ~/.omniroute/storage.sqlite

# Start fresh
omniroute serve
```

### Contact Support

- [OmniRoute GitHub Issues](https://github.com/omniroute/omniroute/issues)
- [OmniRoute Discord](https://discord.gg/omniroute)
- [OmniRoute Documentation](https://omniroute.dev/docs)

---

## 📚 Related Guides

- [API Keys Guide](API_KEYS_GUIDE.md) — Get API keys for providers
- [Combo Customization](COMBO_CUSTOMIZATION.md) — Create and optimize combos
- [Setup Script](../scripts/setup.sh) — Automated setup

---

**Last updated**: 2026-09-04
