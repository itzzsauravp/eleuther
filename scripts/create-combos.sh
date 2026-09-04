#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Create OmniRoute Combos
# ═══════════════════════════════════════════════════════════════
# This script creates all the routing combos for OmniRoute

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✖ $1${NC}"; }

print_header "Creating OmniRoute Combos"

# Delete existing combos (ignore errors)
echo "Cleaning up existing combos..."
for combo in mega-free free-fallback no-auth-only round-robin-free coding-focused fast-inference heavy-reasoning; do
    omniroute combo delete "$combo" 2>/dev/null || true
done
print_success "Cleaned up existing combos"

# Get list of configured providers
echo ""
echo "📋 Checking configured providers..."
CONFIGURED_PROVIDERS=$(omniroute providers list 2>&1 | grep -E "^[a-f0-9]" | awk '{print $2}' | sort -u)
echo "Configured: $CONFIGURED_PROVIDERS"

# Helper function to create combo if provider exists
create_combo_if_exists() {
    local NAME="$1"
    local STRATEGY="$2"
    shift 2
    local MODELS=("$@")

    # Filter to only configured providers
    local VALID_MODELS=()
    for model in "${MODELS[@]}"; do
        local PROVIDER=$(echo "$model" | cut -d'/' -f1)
        if echo "$CONFIGURED_PROVIDERS" | grep -q "^${PROVIDER}$"; then
            VALID_MODELS+=("$model")
        fi
    done

    if [ ${#VALID_MODELS[@]} -gt 0 ]; then
        echo -n "Creating $NAME combo (${#VALID_MODELS[@]} models)... "

        MODEL_ARGS=""
        for model in "${VALID_MODELS[@]}"; do
            MODEL_ARGS="$MODEL_ARGS --model $model"
        done

        if omniroute combo create "$NAME" --strategy "$STRATEGY" $MODEL_ARGS 2>&1 | grep -q "created"; then
            print_success "$NAME created"
        else
            print_warning "$NAME may already exist or failed"
        fi
    else
        print_warning "Skipping $NAME - no configured providers"
    fi
}

# Create mega-free combo
print_header "Creating Combos"

create_combo_if_exists "mega-free" "priority" \
    "aihorde/any" \
    "opencode/auto" \
    "huggingchat/auto" \
    "ollama-cloud/auto" \
    "zcode/auto" \
    "firecrawl/auto" \
    "searxng-search/auto" \
    "gemini/auto" \
    "groq/auto" \
    "nvidia/auto" \
    "cerebras/auto" \
    "sambanova/auto" \
    "deepseek/auto" \
    "mistral/auto" \
    "cohere/auto" \
    "huggingface/auto" \
    "deepinfra/auto" \
    "fireworks/auto" \
    "nebius/auto" \
    "siliconflow/auto" \
    "hyperbolic/auto" \
    "featherless/auto" \
    "friendli/auto" \
    "nscale/auto" \
    "baseten/auto" \
    "bytez/auto" \
    "modelscope/auto" \
    "pollinations/auto" \
    "inference-net/auto" \
    "openrouter/auto" \
    "requesty/auto" \
    "anyapi/auto" \
    "freebuff/auto" \
    "freeinference/auto" \
    "free-ai/auto" \
    "freetheai/auto" \
    "dgrid/auto" \
    "tokenreply/auto" \
    "yolo-auto/auto" \
    "zenmux/auto" \
    "openadapter/auto" \
    "api-airforce/auto" \
    "bazaarlink/auto" \
    "dahl/auto" \
    "llm7/auto" \
    "novita/auto" \
    "bluesminds/auto" \
    "freemodel-dev/auto" \
    "freeaiapikey/auto"

# Create free-fallback combo
create_combo_if_exists "free-fallback" "priority" \
    "aihorde/any" \
    "ollama-cloud/auto" \
    "opencode/auto" \
    "huggingchat/auto" \
    "gemini/auto" \
    "groq/auto" \
    "nvidia/auto" \
    "cerebras/auto" \
    "sambanova/auto" \
    "deepseek/auto" \
    "mistral/auto" \
    "cohere/auto"

# Create no-auth-only combo
create_combo_if_exists "no-auth-only" "priority" \
    "aihorde/any" \
    "opencode/auto" \
    "huggingchat/auto" \
    "ollama-cloud/auto" \
    "zcode/auto"

# Create round-robin-free combo
create_combo_if_exists "round-robin-free" "round-robin" \
    "aihorde/any" \
    "opencode/auto" \
    "huggingchat/auto" \
    "ollama-cloud/auto" \
    "zcode/auto"

# Create coding-focused combo
create_combo_if_exists "coding-focused" "priority" \
    "deepseek/deepseek-coder" \
    "mistral/codestral-latest" \
    "groq/llama-3.3-70b-versatile" \
    "nvidia/llama-3.1-70b-instruct" \
    "cerebras/llama3.1-70b" \
    "sambanova/llama-3.1-70b" \
    "gemini/gemini-2.0-flash" \
    "aihorde/any"

# Create fast-inference combo
create_combo_if_exists "fast-inference" "priority" \
    "cerebras/llama3.1-8b" \
    "groq/llama-3.1-8b-instant" \
    "sambanova/llama-3.1-8b" \
    "nvidia/llama-3.1-8b-instruct" \
    "deepinfra/meta-llama/Meta-Llama-3.1-8B-Instruct" \
    "aihorde/any"

# Create heavy-reasoning combo
create_combo_if_exists "heavy-reasoning" "priority" \
    "deepseek/deepseek-reasoner" \
    "nvidia/llama-3.1-405b-instruct" \
    "nvidia/nemotron-4-340b-instruct" \
    "gemini/gemini-1.5-pro" \
    "mistral/mistral-large-latest" \
    "cohere/command-r-plus" \
    "aihorde/any"

# Summary
print_header "Combo Creation Complete"

echo "Created combos:"
omniroute combo list 2>&1 | grep -E "○|●" | head -20

echo ""
echo "To activate a combo:"
echo "  omniroute combo switch mega-free"
echo ""
echo "To test a combo:"
echo "  omniroute simulate 'Write a Python function' --combo mega-free --explain"
echo ""
echo "To manage combos:"
echo "  ~/.omniroute/combos.sh list"
echo "  ~/.omniroute/combos.sh switch <combo-name>"
