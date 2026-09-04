#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✖ $1${NC}"; }

# Support both api-keys.env and API_KEYS.md
ENV_FILE="${1:-$HOME/.omniroute/api-keys.env}"
if [ ! -f "$ENV_FILE" ] && [ -f "$HOME/.omniroute/API_KEYS.md" ]; then
    ENV_FILE="$HOME/.omniroute/API_KEYS.md"
fi

if [ ! -f "$ENV_FILE" ]; then
    print_error "No API keys file found at $ENV_FILE or ~/.omniroute/api-keys.env"
    exit 1
fi

echo "📖 Reading API keys from: $ENV_FILE"
echo ""

# Supported providers mapping
declare -A PROVIDER_MAP=(
    ["gemini"]="gemini" ["groq"]="groq" ["nvidia"]="nvidia"
    ["cerebras"]="cerebras" ["sambanova"]="sambanova" ["deepseek"]="deepseek"
    ["mistral"]="mistral" ["cohere"]="cohere" ["huggingface"]="huggingface"
    ["deepinfra"]="deepinfra" ["fireworks"]="fireworks" ["nebius"]="nebius"
    ["siliconflow"]="siliconflow" ["hyperbolic"]="hyperbolic"
    ["featherless"]="featherless" ["friendli"]="friendli" ["nscale"]="nscale"
    ["baseten"]="baseten" ["bytez"]="bytez" ["modelscope"]="modelscope"
    ["pollinations"]="pollinations" ["inference-net"]="inference-net"
    ["reka"]="reka" ["ai21"]="ai21" ["nous"]="nous"
    ["inception"]="inception" ["scaleway"]="scaleway" ["cloudflare-ai"]="cloudflare-ai"
    ["modal"]="modal" ["vertex"]="vertex" ["pioneer"]="pioneer"
    ["morph"]="morph" ["openrouter"]="openrouter" ["requesty"]="requesty"
    ["anyapi"]="anyapi" ["freebuff"]="freebuff" ["freeinference"]="freeinference"
    ["free-ai"]="free-ai" ["freetheai"]="freetheai" ["dgrid"]="dgrid"
    ["tokenreply"]="tokenreply" ["yolo-auto"]="yolo-auto" ["zenmux"]="zenmux"
    ["openadapter"]="openadapter" ["api-airforce"]="api-airforce"
    ["bazaarlink"]="bazaarlink" ["dahl"]="dahl" ["llm7"]="llm7"
    ["novita"]="novita" ["bluesminds"]="bluesminds" ["freemodel-dev"]="freemodel-dev"
    ["freeaiapikey"]="freeaiapikey"
    # ENV variant mapping
    ["GEMINI_API_KEY"]="gemini" ["GROQ_API_KEY"]="groq" ["NVIDIA_API_KEY"]="nvidia"
    ["CEREBRAS_API_KEY"]="cerebras" ["SAMBANOVA_API_KEY"]="sambanova" ["DEEPSEEK_API_KEY"]="deepseek"
    ["MISTRAL_API_KEY"]="mistral" ["COHERE_API_KEY"]="cohere" ["HUGGINGFACE_API_KEY"]="huggingface"
    ["DEEPINFRA_API_KEY"]="deepinfra" ["FIREWORKS_API_KEY"]="fireworks" ["NEBIUS_API_KEY"]="nebius"
    ["SILICONFLOW_API_KEY"]="siliconflow" ["HYPERBOLIC_API_KEY"]="hyperbolic"
    ["FEATHERLESS_API_KEY"]="featherless" ["FRIENDLI_API_KEY"]="friendli" ["NSCALE_API_KEY"]="nscale"
    ["BASETEN_API_KEY"]="baseten" ["BYTEZ_API_KEY"]="bytez" ["MODELSCOPE_API_KEY"]="modelscope"
    ["POLLINATIONS_API_KEY"]="pollinations" ["INFERENCE_NET_API_KEY"]="inference-net"
)

ADDED=0
SKIPPED=0

while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    # Extract key and value (handling provider=key or provider='key' or provider="key")
    if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*=[[:space:]]*[\x27\x22]?([^[:space:]\x27\x22]+)[\x27\x22]?[[:space:]]*$ ]]; then
        prov="${BASH_REMATCH[1]}"
        val="${BASH_REMATCH[2]}"

        # Normalize provider name to lowercase
        prov_lower=$(echo "$prov" | tr '[:upper:]' '[:lower:]')

        PROVIDER_ID="${PROVIDER_MAP[$prov_lower]}"
        if [ -n "$PROVIDER_ID" ] && [ -n "$val" ]; then
            echo -n "Registering $PROVIDER_ID... "
            OUTPUT=$(omniroute providers add "$PROVIDER_ID" --credential "$val" --yes 2>&1)
            if echo "$OUTPUT" | grep -q "Added"; then
                print_success "added"
                ((ADDED++))
            elif echo "$OUTPUT" | grep -q "already"; then
                print_warning "already exists (updated/skipped)"
                ((SKIPPED++))
            else
                print_error "failed"
                echo "  Error: $OUTPUT" | head -2
            fi
        fi
    fi
done < "$ENV_FILE"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo " Summary"
echo "═══════════════════════════════════════════════════════════════"
print_success "Successfully registered/checked: $ADDED providers"
echo ""
echo "Current active providers:"
omniroute providers list 2>&1 | grep -E "^[a-f0-9]" | head -20
