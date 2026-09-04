#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# OmniRoute Free Token Maximizer — Setup Script
# ═══════════════════════════════════════════════════════════════
# This script automates the setup of OmniRoute with free providers
# and smart fallback combos.
#
# COMBO ORDERING STRATEGY:
#   - Limited free tier providers FIRST (burn through quotas)
#   - Unlimited/no-auth providers LAST (ultimate safety net)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

check_omniroute() {
    print_header "Checking OmniRoute Installation"
    if command -v omniroute &> /dev/null; then
        VERSION=$(omniroute --version 2>&1 | head -1)
        print_success "OmniRoute installed: $VERSION"
        return 0
    else
        print_error "OmniRoute not found!"
        echo "Please install OmniRoute first: npm install -g omniroute"
        exit 1
    fi
}

backup_config() {
    print_header "Backing Up Existing Configuration"
    BACKUP_DIR="$HOME/omniroute-backup-$(date +%Y%m%d-%H%M%S)"
    if [ -d "$HOME/.omniroute" ]; then
        cp -r "$HOME/.omniroute" "$BACKUP_DIR"
        print_success "Backup created at: $BACKUP_DIR"
    fi
}

add_noauth_providers() {
    print_header "Adding No-Auth Providers"
    NOAUTH_PROVIDERS=("aihorde" "opencode" "huggingchat" "firecrawl" "searxng-search")
    for provider in "${NOAUTH_PROVIDERS[@]}"; do
        echo -n "Adding $provider... "
        if omniroute providers add "$provider" --no-credential --yes 2>&1 | grep -q "Added"; then
            print_success "$provider added"
        else
            print_warning "$provider may already exist"
        fi
    done
}

add_api_key_providers() {
    print_header "Adding Providers with API Keys"
    ENV_FILE="$HOME/.omniroute/api-keys.env"
    if [ ! -f "$ENV_FILE" ]; then
        print_warning "No api-keys.env found at $ENV_FILE"
        echo "Copy from template: cp configs/api-keys.env.example ~/.omniroute/api-keys.env"
        return 1
    fi

    declare -A PROVIDER_MAP=(
        ["GEMINI_API_KEY"]="gemini" ["GROQ_API_KEY"]="groq" ["NVIDIA_API_KEY"]="nvidia"
        ["CEREBRAS_API_KEY"]="cerebras" ["SAMBANOVA_API_KEY"]="sambanova" ["DEEPSEEK_API_KEY"]="deepseek"
        ["MISTRAL_API_KEY"]="mistral" ["COHERE_API_KEY"]="cohere" ["HUGGINGFACE_API_KEY"]="huggingface"
        ["DEEPINFRA_API_KEY"]="deepinfra" ["FIREWORKS_API_KEY"]="fireworks" ["NEBIUS_API_KEY"]="nebius"
        ["SILICONFLOW_API_KEY"]="siliconflow" ["HYPERBOLIC_API_KEY"]="hyperbolic"
        ["FEATHERLESS_API_KEY"]="featherless" ["FRIENDLI_API_KEY"]="friendli" ["NSCALE_API_KEY"]="nscale"
        ["BASETEN_API_KEY"]="baseten" ["BYTEZ_API_KEY"]="bytez" ["MODELSCOPE_API_KEY"]="modelscope"
        ["POLLINATIONS_API_KEY"]="pollinations" ["INFERENCE_NET_API_KEY"]="inference-net"
        ["REKA_API_KEY"]="reka" ["AI21_API_KEY"]="ai21" ["NOUS_API_KEY"]="nous"
        ["INCEPTION_API_KEY"]="inception" ["SCALEWAY_API_KEY"]="scaleway" ["CLOUDFLARE_AI_API_KEY"]="cloudflare-ai"
        ["MODAL_API_KEY"]="modal" ["VERTEX_API_KEY"]="vertex" ["PIONEER_API_KEY"]="pioneer"
        ["MORPH_API_KEY"]="morph" ["OPENROUTER_API_KEY"]="openrouter" ["REQUESTY_API_KEY"]="requesty"
        ["ANYAPI_API_KEY"]="anyapi" ["FREEBUFF_API_KEY"]="freebuff" ["FREEINFERENCE_API_KEY"]="freeinference"
        ["FREE_AI_API_KEY"]="free-ai" ["FREETHEAI_API_KEY"]="freetheai" ["DGRID_API_KEY"]="dgrid"
        ["TOKENREPLY_API_KEY"]="tokenreply" ["YOLO_AUTO_API_KEY"]="yolo-auto" ["ZENMUX_API_KEY"]="zenmux"
        ["OPENADAPTER_API_KEY"]="openadapter" ["API_AIRFORCE_API_KEY"]="api-airforce"
        ["BAZAARLINK_API_KEY"]="bazaarlink" ["DAHL_API_KEY"]="dahl" ["LLM7_API_KEY"]="llm7"
        ["NOVITA_API_KEY"]="novita" ["BLUESMINDS_API_KEY"]="bluesminds" ["FREEMODEL_DEV_API_KEY"]="freemodel-dev"
        ["FREEAIAPIKEY_API_KEY"]="freeaiapikey"
    )

    ADDED_COUNT=0
    while IFS='=' read -r key value; do
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue
        key=$(echo "$key" | xargs); value=$(echo "$value" | xargs)
        [ -z "$value" ] && continue
        PROVIDER_ID="${PROVIDER_MAP[$key]}"
        if [ -n "$PROVIDER_ID" ]; then
            echo -n "Adding $PROVIDER_ID... "
            if omniroute providers add "$PROVIDER_ID" --credential "$value" --yes 2>&1 | grep -q "Added"; then
                print_success "$PROVIDER_ID added"; ((ADDED_COUNT++))
            else
                print_warning "$PROVIDER_ID failed or exists"
            fi
        fi
    done < "$ENV_FILE"
    print_success "Added $ADDED_COUNT providers with API keys"
}

create_combos() {
    print_header "Creating Routing Combos (Limited First → Unlimited Last)"
    CONFIGURED=$(omniroute providers list 2>&1 | grep -E "^[a-f0-9]" | awk '{print $2}' | sort -u)

    create_if_exists() {
        local NAME="$1" STRATEGY="$2"; shift 2
        local MODELS=("$@") VALID_ARGS=""
        for m in "${MODELS[@]}"; do
            local P=$(echo "$m" | cut -d'/' -f1)
            if echo "$CONFIGURED" | grep -q "^${P}$"; then
                VALID_ARGS="$VALID_ARGS --model $m"
            fi
        done
        if [ -n "$VALID_ARGS" ]; then
            echo -n "Creating $NAME... "
            if omniroute combo create "$NAME" --strategy "$STRATEGY" $VALID_ARGS 2>&1 | grep -q "created"; then
                print_success "$NAME created"
            else
                print_warning "$NAME may exist or failed"
            fi
        fi
    }

    # mega-free: 45+ providers, limited first → unlimited last
    create_if_exists "mega-free" "priority" \
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
        "freeaiapikey/auto" \
        "firecrawl/auto" \
        "searxng-search/auto" \
        "aihorde/any" \
        "opencode/auto"

    # free-fallback: core providers
    create_if_exists "free-fallback" "priority" \
        "gemini/auto" \
        "groq/auto" \
        "nvidia/auto" \
        "cerebras/auto" \
        "sambanova/auto" \
        "deepseek/auto" \
        "mistral/auto" \
        "cohere/auto" \
        "aihorde/any" \
        "opencode/auto"

    # coding-focused: code-specialized models
    create_if_exists "coding-focused" "priority" \
        "deepseek/deepseek-coder" \
        "mistral/codestral-latest" \
        "groq/llama-3.3-70b-versatile" \
        "nvidia/llama-3.1-70b-instruct" \
        "cerebras/llama3.1-70b" \
        "sambanova/llama-3.1-70b" \
        "gemini/gemini-2.0-flash" \
        "aihorde/any" \
        "opencode/auto"

    # fast-inference: speed-optimized
    create_if_exists "fast-inference" "priority" \
        "cerebras/llama3.1-8b" \
        "groq/llama-3.1-8b-instant" \
        "sambanova/llama-3.1-8b" \
        "nvidia/llama-3.1-8b-instruct" \
        "deepinfra/meta-llama/Meta-Llama-3.1-8B-Instruct" \
        "aihorde/any" \
        "opencode/auto"

    # heavy-reasoning: complex reasoning tasks
    create_if_exists "heavy-reasoning" "priority" \
        "deepseek/deepseek-reasoner" \
        "nvidia/llama-3.1-405b-instruct" \
        "nvidia/nemotron-4-340b-instruct" \
        "gemini/gemini-1.5-pro" \
        "mistral/mistral-large-latest" \
        "cohere/command-r-plus" \
        "aihorde/any" \
        "opencode/auto"
}

test_setup() {
    print_header "Testing Setup"
    omniroute simulate "Hello, this is a test" --combo mega-free --explain 2>&1 | tail -20
}

print_summary() {
    print_header "Setup Complete!"
    echo "Next steps:"
    echo "  1. Add API keys: nano ~/.omniroute/api-keys.env"
    echo "  2. Run: ./scripts/add-keys.sh"
    echo "  3. Activate: omniroute combo switch mega-free"
    echo ""
    echo "COMBO ORDERING STRATEGY:"
    echo "  - Limited free tier providers FIRST (burn through quotas)"
    echo "  - Unlimited/no-auth providers LAST (safety net)"
    echo "  - See docs/COMBO_CUSTOMIZATION.md for details"
}

main() {
    check_omniroute
    backup_config
    add_noauth_providers
    add_api_key_providers
    create_combos
    test_setup
    print_summary
}

main "$@"
