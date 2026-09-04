#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Add API Keys to OmniRoute
# ═══════════════════════════════════════════════════════════════
# This script reads API keys from api-keys.env and adds them to OmniRoute

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✖ $1${NC}"; }

ENV_FILE="${1:-$HOME/.omniroute/api-keys.env}"

if [ ! -f "$ENV_FILE" ]; then
    print_error "API keys file not found: $ENV_FILE"
    echo ""
    echo "Please create it from the template:"
    echo "  cp configs/api-keys.env.example $ENV_FILE"
    echo "  nano $ENV_FILE"
    exit 1
fi

echo "📖 Reading API keys from: $ENV_FILE"
echo ""

# Provider mapping
declare -A PROVIDER_MAP=(
    ["GEMINI_API_KEY"]="gemini"
    ["GROQ_API_KEY"]="groq"
    ["NVIDIA_API_KEY"]="nvidia"
    ["CEREBRAS_API_KEY"]="cerebras"
    ["SAMBANOVA_API_KEY"]="sambanova"
    ["DEEPSEEK_API_KEY"]="deepseek"
    ["MISTRAL_API_KEY"]="mistral"
    ["COHERE_API_KEY"]="cohere"
    ["HUGGINGFACE_API_KEY"]="huggingface"
    ["DEEPINFRA_API_KEY"]="deepinfra"
    ["FIREWORKS_API_KEY"]="fireworks"
    ["NEBIUS_API_KEY"]="nebius"
    ["SILICONFLOW_API_KEY"]="siliconflow"
    ["HYPERBOLIC_API_KEY"]="hyperbolic"
    ["FEATHERLESS_API_KEY"]="featherless"
    ["FRIENDLI_API_KEY"]="friendli"
    ["NSCALE_API_KEY"]="nscale"
    ["BASETEN_API_KEY"]="baseten"
    ["BYTEZ_API_KEY"]="bytez"
    ["MODELSCOPE_API_KEY"]="modelscope"
    ["POLLINATIONS_API_KEY"]="pollinations"
    ["INFERENCE_NET_API_KEY"]="inference-net"
    ["REKA_API_KEY"]="reka"
    ["AI21_API_KEY"]="ai21"
    ["NOUS_API_KEY"]="nous"
    ["INCEPTION_API_KEY"]="inception"
    ["SCALEWAY_API_KEY"]="scaleway"
    ["CLOUDFLARE_AI_API_KEY"]="cloudflare-ai"
    ["MODAL_API_KEY"]="modal"
    ["VERTEX_API_KEY"]="vertex"
    ["PIONEER_API_KEY"]="pioneer"
    ["MORPH_API_KEY"]="morph"
    ["OPENROUTER_API_KEY"]="openrouter"
    ["REQUESTY_API_KEY"]="requesty"
    ["ANYAPI_API_KEY"]="anyapi"
    ["FREEBUFF_API_KEY"]="freebuff"
    ["FREEINFERENCE_API_KEY"]="freeinference"
    ["FREE_AI_API_KEY"]="free-ai"
    ["FREETHEAI_API_KEY"]="freetheai"
    ["DGRID_API_KEY"]="dgrid"
    ["TOKENREPLY_API_KEY"]="tokenreply"
    ["YOLO_AUTO_API_KEY"]="yolo-auto"
    ["ZENMUX_API_KEY"]="zenmux"
    ["OPENADAPTER_API_KEY"]="openadapter"
    ["API_AIRFORCE_API_KEY"]="api-airforce"
    ["BAZAARLINK_API_KEY"]="bazaarlink"
    ["DAHL_API_KEY"]="dahl"
    ["LLM7_API_KEY"]="llm7"
    ["NOVITA_API_KEY"]="novita"
    ["BLUESMINDS_API_KEY"]="bluesminds"
    ["FREEMODEL_DEV_API_KEY"]="freemodel-dev"
    ["FREEAIAPIKEY_API_KEY"]="freeaiapikey"
)

ADDED=0
SKIPPED=0

while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue

    # Trim whitespace
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)

    # Skip if no value
    if [ -z "$value" ]; then
        continue
    fi

    # Get provider ID
    PROVIDER_ID="${PROVIDER_MAP[$key]}"

    if [ -n "$PROVIDER_ID" ]; then
        echo -n "Adding $PROVIDER_ID... "

        OUTPUT=$(omniroute providers add "$PROVIDER_ID" --credential "$value" --yes 2>&1)

        if echo "$OUTPUT" | grep -q "Added"; then
            print_success "added"
            ((ADDED++))
        elif echo "$OUTPUT" | grep -q "already"; then
            print_warning "already exists"
            ((SKIPPED++))
        else
            print_error "failed"
            echo "  Error: $OUTPUT" | head -3
        fi
    fi
done < "$ENV_FILE"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " Summary"
echo "═══════════════════════════════════════════════════════════════"
print_success "Added: $ADDED providers"
print_warning "Skipped: $SKIPPED (already exist)"
echo ""
echo "Current providers:"
omniroute providers list 2>&1 | grep -E "^[a-f0-9]" | head -20
echo ""
echo "Next: Run ./scripts/create-combos.sh to create/update combos"
