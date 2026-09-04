#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Add API Keys to OmniRoute — Reads from ~/.omniroute/api-keys.env
# ═══════════════════════════════════════════════════════════════
# This script reads API keys from ~/.omniroute/api-keys.env and
# registers each provider with OmniRoute.

# Don't use set -e because we want to continue even if one provider fails

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✖ $1${NC}"; }
print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Support both api-keys.env and API_KEYS.md
ENV_FILE="${1:-$HOME/.omniroute/api-keys.env}"
if [ ! -f "$ENV_FILE" ] && [ -f "$HOME/.omniroute/API_KEYS.md" ]; then
    ENV_FILE="$HOME/.omniroute/API_KEYS.md"
fi

if [ ! -f "$ENV_FILE" ]; then
    print_error "No API keys file found at $ENV_FILE"
    echo ""
    echo "Create it by copying the template:"
    echo "  cp configs/api-keys.env.example ~/.omniroute/api-keys.env"
    echo "  nano ~/.omniroute/api-keys.env  # add your keys"
    exit 1
fi

print_header "Reading API keys from: $ENV_FILE"

# Map ENV var names to OmniRoute provider IDs
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
FAILED=0

# Read file line by line, handling KEY=value pairs
while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue

    # Extract KEY=value (strip optional quotes)
    if [[ "$line" =~ ^[[:space:]]*([A-Za-z][A-Za-z0-9_-]*)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
        KEY="${BASH_REMATCH[1]}"
        VALUE="${BASH_REMATCH[2]}"

        # Strip surrounding quotes from value
        VALUE="${VALUE%\"}"
        VALUE="${VALUE#\"}"
        VALUE="${VALUE%\'}"
        VALUE="${VALUE#\'}"

        # Trim whitespace
        KEY="$(echo "$KEY" | xargs)"
        VALUE="$(echo "$VALUE" | xargs)"

        # Skip empty values
        [ -z "$VALUE" ] && continue

        PROVIDER_ID="${PROVIDER_MAP[$KEY]}"
        if [ -n "$PROVIDER_ID" ]; then
            echo -n "  Registering $PROVIDER_ID... "
            OUTPUT=$(omniroute providers add "$PROVIDER_ID" --credential "$VALUE" --yes 2>&1 || true)
            if echo "$OUTPUT" | grep -q "Added"; then
                print_success "added"
                ((ADDED++))
            elif echo "$OUTPUT" | grep -q "already"; then
                print_warning "already exists"
                ((SKIPPED++))
            else
                print_error "failed"
                echo "    Output: $(echo "$OUTPUT" | head -3)"
                ((FAILED++))
            fi
        else
            print_warning "Skipping unknown key: $KEY"
        fi
    fi
done < "$ENV_FILE"

print_header "Summary"
print_success "Added: $ADDED"
echo "  Skipped: $SKIPPED"
echo "  Failed:  $FAILED"
echo ""

echo "Currently active providers:"
omniroute providers list 2>&1 | grep -E "^[a-f0-9]" | awk '{printf "  - %s\n", $2}'