#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Eleuther — Register API Keys & Build Intelligent Combos
# ═══════════════════════════════════════════════════════════════
# 1. Inspects ~/.omniroute/api-keys.env for active user API keys
# 2. Validates keys (aborts if empty or template-only)
# 3. Registers providers securely into OmniRoute's encrypted store
# 4. Compiles and activates multi-tier failover combos
# 5. Verifies routing with a live simulation dry-run
# ═══════════════════════════════════════════════════════════════

set +e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error()   { echo -e "${RED}✖ $1${NC}"; }
print_info()    { echo -e "${CYAN}→ $1${NC}"; }
print_header() {
    echo ""; echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"; echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"; echo ""
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ENV_FILE="${1:-$HOME/.omniroute/api-keys.env}"

# Check file existence
if [ ! -f "$ENV_FILE" ]; then
    print_error "API keys file not found: $ENV_FILE"
    echo ""
    if [ -f "$REPO_ROOT/configs/api-keys.env.example" ]; then
        mkdir -p "$HOME/.omniroute"
        cp "$REPO_ROOT/configs/api-keys.env.example" "$ENV_FILE"
        chmod 600 "$ENV_FILE" 2>/dev/null || true
        print_info "Created template at: $ENV_FILE"
    fi
    echo -e "Please edit the file with your keys:"
    echo -e "  ${CYAN}nano $ENV_FILE${NC}"
    echo -e "Then re-run this script:"
    echo -e "  ${CYAN}./scripts/register-keys.sh${NC}"
    exit 1
fi

print_header "Step 1/3 — Validating API Keys in: $ENV_FILE"

# Provider mapping table
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

# Detect valid keys
VALID_KEYS=()
VALID_PROVIDERS=()

while IFS= read -r line || [ -n "$line" ]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue

    if [[ "$line" =~ ^[[:space:]]*([A-Za-z][A-Za-z0-9_-]*)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
        KEY="${BASH_REMATCH[1]}"
        VALUE="${BASH_REMATCH[2]}"

        # Strip inline comments
        VALUE="${VALUE%%#*}"

        VALUE="${VALUE%\"}"
        VALUE="${VALUE#\"}"
        VALUE="${VALUE%\'}"
        VALUE="${VALUE#\'}"

        KEY="$(echo "$KEY" | xargs)"
        VALUE="$(echo "$VALUE" | xargs)"

        # Filter out empty or template placeholders
        [ -z "$VALUE" ] && continue
        [[ "$VALUE" == *"your_key_here"* ]] && continue
        [[ "$VALUE" == *"sk-..."* ]] && continue
        [[ "$VALUE" == *"enter_"* ]] && continue

        PROVIDER_ID="${PROVIDER_MAP[$KEY]}"
        if [ -n "$PROVIDER_ID" ]; then
            VALID_KEYS+=("$KEY=$VALUE")
            VALID_PROVIDERS+=("$PROVIDER_ID")
        fi
    fi
done < "$ENV_FILE"

if [ ${#VALID_KEYS[@]} -eq 0 ]; then
    echo ""
    print_error "No active API keys found in $ENV_FILE!"
    echo ""
    echo -e "${YELLOW}Please add at least one valid API key before running this script.${NC}"
    echo -e "  1. Edit:  ${CYAN}nano $ENV_FILE${NC}"
    echo -e "  2. Save your keys and exit nano (Ctrl+O, Enter, Ctrl+X)"
    echo -e "  3. Run:   ${CYAN}./scripts/register-keys.sh${NC}"
    echo ""
    echo -e "Tip: You can get free keys with generous daily limits from:"
    echo -e "  - Google Gemini:   https://aistudio.google.com/"
    echo -e "  - Groq Cloud:      https://console.groq.com/"
    echo -e "  - OpenRouter:      https://openrouter.ai/"
    echo -e "  - Cerebras:        https://cloud.cerebras.ai/"
    echo ""
    exit 1
fi

print_success "Found ${#VALID_KEYS[@]} configured API key(s): ${VALID_PROVIDERS[*]}"

# ═══════════════════════════════════════════════════════════════
# Step 2: Register Providers
# ═══════════════════════════════════════════════════════════════
print_header "Step 2/3 — Registering Providers in OmniRoute"

ADDED=0; SKIPPED=0; FAILED=0

for pair in "${VALID_KEYS[@]}"; do
    KEY="${pair%%=*}"
    VALUE="${pair#*=}"
    PROVIDER_ID="${PROVIDER_MAP[$KEY]}"

    echo -n "  Registering $PROVIDER_ID... "
    OUTPUT=$(omniroute providers add "$PROVIDER_ID" --credential "$VALUE" --yes 2>&1 || true)
    if echo "$OUTPUT" | grep -qi "added\|updated"; then
        print_success "registered"
        ((ADDED++))
    elif echo "$OUTPUT" | grep -qi "already"; then
        print_warning "already configured"
        ((SKIPPED++))
    else
        print_error "failed"
        echo "    $OUTPUT"
        ((FAILED++))
    fi
done

echo ""
print_info "Provider sync: $ADDED registered, $SKIPPED existing, $FAILED failed"

# ═══════════════════════════════════════════════════════════════
# Step 3: Compile Routing Combos
# ═══════════════════════════════════════════════════════════════
print_header "Step 3/3 — Compiling & Testing Failover Combos"

CONFIGURED=$(omniroute providers list 2>&1 | grep -E "^[a-f0-9]" | awk '{print $2}' | sort -u)

# Clean old custom combos to refresh tiers
EXISTING_COMBOS=$(omniroute combo list 2>&1 | grep -E "○|●" | awk '{print $2}' | tr -d ' ' || true)
ALL_COMBOS_TO_CLEAN=$(echo -e "${EXISTING_COMBOS}\ncombo/execution\ncombo/architecture\ncombo/low-cost-batch" | sort -u)
for combo in $ALL_COMBOS_TO_CLEAN; do
    [ -z "$combo" ] && continue
    echo y | omniroute combo delete "$combo" >/dev/null 2>&1 || true
done

create_combo() {
    local NAME="$1" STRATEGY="$2"; shift 2
    local ARGS=()
    for m in "$@"; do
        local P="${m%%/*}"
        local RESOLVED_MODEL="$m"
        local FOUND=false

        if echo "$CONFIGURED" | grep -qx "$P"; then
            FOUND=true
        elif [ "$P" = "cloudflare" ] && echo "$CONFIGURED" | grep -qx "cloudflare-ai"; then
            FOUND=true
            RESOLVED_MODEL="cloudflare-ai/${m#*/}"
        fi

        if [ "$FOUND" = true ]; then
            ARGS+=(--model "$RESOLVED_MODEL")
        fi
    done

    if [ ${#ARGS[@]} -eq 0 ]; then
        print_warning "Skipped $NAME — no matching configured providers"
        return
    fi

    omniroute combo create "$NAME" --strategy "$STRATEGY" "${ARGS[@]}" >/dev/null 2>&1 \
        && print_success "$NAME (${#ARGS[@]} models configured, strategy: $STRATEGY)" \
        || print_warning "Could not create $NAME"
}

# 1. Main Execution & Coding Combo
create_combo "combo/execution" "priority" \
    "groq/llama-3.3-70b-versatile" \
    "cerebras/llama3.1-70b" \
    "sambanova/llama-3.1-70b" \
    "deepseek/deepseek-chat" \
    "mistral/codestral-latest" \
    "gemini/gemini-2.0-flash" \
    "nvidia/llama-3.1-70b-instruct" \
    "cohere/command-r-plus" \
    "siliconflow/deepseek-ai/DeepSeek-V3" \
    "siliconflow/Qwen/Qwen2.5-Coder-32B-Instruct" \
    "openrouter/meta-llama/llama-3.3-70b-instruct:free" \
    "openrouter/qwen/qwen-2.5-coder-32b-instruct:free" \
    "openrouter/auto"

# 2. Deep Reasoning & Architecture Combo
create_combo "combo/architecture" "priority" \
    "deepseek/deepseek-reasoner" \
    "gemini/gemini-2.0-flash-thinking-exp" \
    "groq/deepseek-r1-distill-llama-70b" \
    "nvidia/nemotron-4-340b-instruct" \
    "openrouter/deepseek/deepseek-r1:free"

# 3. High-Speed Low-Cost Combo
create_combo "combo/low-cost-batch" "priority" \
    "cerebras/llama3.1-8b" \
    "groq/llama-3.1-8b-instant" \
    "sambanova/llama-3.1-8b" \
    "nvidia/llama-3.1-8b-instruct" \
    "cloudflare/@cf/meta/llama-3-8b-instruct" \
    "openrouter/meta-llama/llama-3.1-8b-instruct:free"

# Set default active combo
omniroute combo switch combo/execution >/dev/null 2>&1 && print_success "Active default route set to: combo/execution"

# Dry-run validation
echo ""
print_info "Validating combo/execution route with test prompt..."
SIM_OUTPUT=$(omniroute simulate "Write a Python function to calculate factorial" --combo "combo/execution" --explain 2>&1 || true)
if echo "$SIM_OUTPUT" | grep -q "Primary:"; then
    PRIMARY=$(echo "$SIM_OUTPUT" | grep "Primary:" | sed 's/Primary: //')
    print_success "combo/execution is ROUTABLE (Primary: ${PRIMARY})"
else
    print_warning "Simulation did not identify a primary model. Upstream calls will fall back automatically."
fi

echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD} 🎉 API KEYS REGISTERED & COMBOS READY!${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "Active providers and combos are ready to serve requests."
echo -e "Start the local proxy if not running:  ${CYAN}omniroute serve &${NC}"
echo -e "Launch your terminal agent:"
echo -e "  - Claude Code:  ${CYAN}claude${NC}"
echo -e "  - Codex:        ${CYAN}codex${NC}"
echo -e "  - OpenCode:     ${CYAN}opencode${NC}"
echo -e "  - Aider:        ${CYAN}aider${NC}"
echo ""
