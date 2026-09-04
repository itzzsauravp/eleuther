#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# OmniRoute Combo Builder — Production Tiered Architecture
# ═══════════════════════════════════════════════════════════════
# Three tiers per combo:
#   Tier 1: Sub-second native (Groq/Cerebras/SambaNova) — RPM limits reset every 60s
#   Tier 2: Deep logic (DeepSeek/Gemini/Mistral) — daily quotas
#   Tier 3: Unlimited floor (OpenRouter free models) — never fails
# ═══════════════════════════════════════════════════════════════

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_header() {
    echo ""; echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"; echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"; echo ""
}

CONFIGURED=$(omniroute providers list 2>&1 | grep -E "^[a-f0-9]" | awk '{print $2}' | sort -u)
if [ -z "$CONFIGURED" ]; then
    print_warning "No providers configured. Run ./scripts/install.sh first."
    exit 1
fi

# Delete old combos
for combo in combo/execution combo/architecture combo/low-cost-batch; do
    echo y | omniroute combo delete "$combo" >/dev/null 2>&1 || true
done

create() {
    local NAME="$1" STRATEGY="$2"; shift 2
    local ARGS=()
    for m in "$@"; do
        local P="${m%%/*}"
        echo "$CONFIGURED" | grep -qx "$P" && ARGS+=(--model "$m")
    done
    if [ ${#ARGS[@]} -eq 0 ]; then
        print_warning "Skipped $NAME — no matching providers"
        return
    fi
    omniroute combo create "$NAME" --strategy "$STRATEGY" "${ARGS[@]}" >/dev/null 2>&1 \
        && print_success "$NAME (${#ARGS[@]} models, $STRATEGY)" \
        || print_warning "$NAME may already exist"
}

print_header "Building Tiered Combos"

create "combo/execution" "priority" \
	"groq/llama-3.3-70b-versatile" \
	"cerebras/llama3.1-70b" \
	"sambanova/llama-3.1-70b" \
	"deepseek/deepseek-chat" \
	"mistral/codestral-latest" \
	"gemini/gemini-2.0-flash" \
	"siliconflow/deepseek-ai/DeepSeek-V3" \
	"siliconflow/Qwen/Qwen2.5-Coder-32B-Instruct" \
	"openrouter/meta-llama/llama-3.3-70b-instruct:free" \
	"openrouter/qwen/qwen-2.5-coder-32b-instruct:free" \
	"openrouter/auto"

create "combo/architecture" "priority" \
	"deepseek/deepseek-reasoner" \
	"gemini/gemini-2.0-flash-thinking-exp" \
	"groq/deepseek-r1-distill-llama-70b" \
	"openrouter/deepseek/deepseek-r1:free"

create "combo/low-cost-batch" "priority" \
	"cerebras/llama3.1-8b" \
	"groq/llama-3.1-8b-instant" \
	"cloudflare/@cf/meta/llama-3-8b-instruct" \
	"openrouter/meta-llama/llama-3.1-8b-instruct:free"

print_header "Combos Built"
omniroute combo list 2>&1 | grep -E "○|●" | grep -E "combo/(execution|architecture|low-cost-batch)"

if [ "$1" = "--switch" ]; then
    omniroute combo switch combo/execution >/dev/null 2>&1 && print_success "combo/execution activated"
fi
