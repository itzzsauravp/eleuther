#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# OmniRoute Combo Builder & Validator
# Production Agentic & Coding Edition
# ═══════════════════════════════════════════════════════════════
# Strategy:
#   Tier 1: Ultra-fast LPU/Hardware execution (<1s latency)
#   Tier 2: High-intelligence SOTA Coding & Reasoning models
#   Tier 3: Enterprise fallback APIs (Nvidia, Mistral, Cohere)
#   Tier 4: Guaranteed OpenRouter free floor (Never fails)
#
# Flags:
#   --switch     Activate combo/execution after building
#   --test-only  Skip build and test existing combos
#   --skip-test  Skip the post-build verification test
# ═══════════════════════════════════════════════════════════════

set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error()   { echo -e "${RED}✖ $1${NC}"; }
print_info()    { echo -e "${CYAN}→ $1${NC}"; }
print_header() {
    echo ""; echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"; echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"; echo ""
}

DO_SWITCH=false
TEST_ONLY=false
SKIP_TEST=false

for arg in "$@"; do
    case "$arg" in
        --switch)    DO_SWITCH=true ;;
        --test-only) TEST_ONLY=true ;;
        --skip-test) SKIP_TEST=true ;;
    esac
done

test_combos() {
    print_header "Validating Routing Combos"
    local TARGET_COMBOS=("combo/execution" "combo/architecture" "combo/low-cost-batch")
    local TEST_PROMPT="Write a Python function to calculate factorial"

    for combo in "${TARGET_COMBOS[@]}"; do
        echo -e "${CYAN}Testing ${combo}...${NC}"
        local SIM_OUTPUT
        SIM_OUTPUT=$(omniroute simulate "$TEST_PROMPT" --combo "$combo" --explain 2>&1 || true)

        if echo "$SIM_OUTPUT" | grep -q "Primary:"; then
            local PRIMARY
            PRIMARY=$(echo "$SIM_OUTPUT" | grep "Primary:" | sed 's/Primary: //')
            print_success "${combo} is ACTIVE & ROUTABLE (Primary: ${PRIMARY})"
        else
            print_warning "${combo} simulation returned no primary route. Check provider configuration."
        fi
    done
}

if [ "$TEST_ONLY" = true ]; then
    test_combos
    exit 0
fi

CONFIGURED=$(omniroute providers list 2>&1 | grep -E "^[a-f0-9]" | awk '{print $2}' | sort -u)
if [ -z "$CONFIGURED" ]; then
    print_warning "No providers configured. Configure your providers in OmniRoute first."
    exit 1
fi

print_header "Cleaning Existing Combos"
EXISTING_COMBOS=$(omniroute combo list 2>&1 | grep -E "○|●" | awk '{print $2}' | tr -d ' ' || true)
ALL_COMBOS_TO_CLEAN=$(echo -e "${EXISTING_COMBOS}\nmega-free\nfree-fallback\nno-auth-only\nround-robin-free\ncoding-focused\nfast-inference\nheavy-reasoning\ncombo/execution\ncombo/architecture\ncombo/low-cost-batch" | sort -u)

for combo in $ALL_COMBOS_TO_CLEAN; do
    [ -z "$combo" ] && continue
    echo y | omniroute combo delete "$combo" >/dev/null 2>&1 || true
done
print_success "Combos cleaned up"

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
        || print_warning "Failed or partially created $NAME"
}

print_header "Building Production Agentic & Coding Combos"

# 1. Main Execution & Coding Combo (For coding, agents, tool use)
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

# 2. Deep Reasoning & Architecture Combo (For complex debugging & algorithm design)
create_combo "combo/architecture" "priority" \
    "deepseek/deepseek-reasoner" \
    "gemini/gemini-2.0-flash-thinking-exp" \
    "groq/deepseek-r1-distill-llama-70b" \
    "nvidia/nemotron-4-340b-instruct" \
    "openrouter/deepseek/deepseek-r1:free"

# 3. High-Speed Low-Cost Combo (For small scripts, string formatting, embeddings/filtering)
create_combo "combo/low-cost-batch" "priority" \
    "cerebras/llama3.1-8b" \
    "groq/llama-3.1-8b-instant" \
    "sambanova/llama-3.1-8b" \
    "nvidia/llama-3.1-8b-instruct" \
    "cloudflare/@cf/meta/llama-3-8b-instruct" \
    "openrouter/meta-llama/llama-3.1-8b-instruct:free"

print_header "Combos Registered"
omniroute combo list 2>&1 | grep -E "combo/(execution|architecture|low-cost-batch)"

if [ "$DO_SWITCH" = true ]; then
    omniroute combo switch combo/execution >/dev/null 2>&1 && print_success "Switched default active combo to combo/execution"
fi

if [ "$SKIP_TEST" = false ]; then
    test_combos
fi
