#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# OmniRoute Free Token Maximizer — Setup Script
# ═══════════════════════════════════════════════════════════════
# This script automates the setup of OmniRoute with free providers
# and smart fallback combos.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✖ $1${NC}"
}

# Check if OmniRoute is installed
check_omniroute() {
    print_header "Checking OmniRoute Installation"

    if command -v omniroute &> /dev/null; then
        VERSION=$(omniroute --version 2>&1 | head -1)
        print_success "OmniRoute installed: $VERSION"
        return 0
    else
        print_error "OmniRoute not found!"
        echo ""
        echo "Please install OmniRoute first:"
        echo "  npm install -g omniroute"
        echo ""
        echo "Or visit: https://omniroute.dev/install"
        exit 1
    fi
}

# Backup existing configuration
backup_config() {
    print_header "Backing Up Existing Configuration"

    BACKUP_DIR="$HOME/omniroute-backup-$(date +%Y%m%d-%H%M%S)"

    if [ -d "$HOME/.omniroute" ]; then
        cp -r "$HOME/.omniroute" "$BACKUP_DIR"
        print_success "Backup created at: $BACKUP_DIR"
    else
        print_warning "No existing configuration found, skipping backup"
    fi
}

# Add no-auth providers
add_noauth_providers() {
    print_header "Adding No-Auth Providers (No API Key Needed)"

    NOAUTH_PROVIDERS=(
        "aihorde"
        "opencode"
        "huggingchat"
        "firecrawl"
        "searxng-search"
    )

    for provider in "${NOAUTH_PROVIDERS[@]}"; do
        echo -n "Adding $provider... "
        if omniroute providers add "$provider" --no-credential --yes 2>&1 | grep -q "Added"; then
            print_success "$provider added"
        else
            print_warning "$provider may already exist or failed"
        fi
    done
}

# Add providers from API keys file
add_api_key_providers() {
    print_header "Adding Providers with API Keys"

    ENV_FILE="$HOME/.omniroute/api-keys.env"

    if [ ! -f "$ENV_FILE" ]; then
        print_warning "No api-keys.env file found at $ENV_FILE"
        echo "Please copy api-keys.env.example to api-keys.env and add your keys"
        echo "  cp configs/api-keys.env.example ~/.omniroute/api-keys.env"
        echo "  nano ~/.omniroute/api-keys.env"
        return 1
    fi

    # Provider mapping (env var name -> omniroute provider id)
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

    ADDED_COUNT=0

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

        # Get provider ID from map
        PROVIDER_ID="${PROVIDER_MAP[$key]}"

        if [ -n "$PROVIDER_ID" ]; then
            echo -n "Adding $PROVIDER_ID... "
            if omniroute providers add "$PROVIDER_ID" --credential "$value" --yes 2>&1 | grep -q "Added\|already"; then
                print_success "$PROVIDER_ID added"
                ((ADDED_COUNT++))
            else
                print_warning "$PROVIDER_ID failed or already exists"
            fi
        fi
    done < "$ENV_FILE"

    echo ""
    print_success "Added $ADDED_COUNT providers with API keys"
}

# Create all combos
create_combos() {
    print_header "Creating Routing Combos"

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    COMBOS_JSON="$SCRIPT_DIR/../configs/combos.json"

    if [ ! -f "$COMBOS_JSON" ]; then
        print_error "combos.json not found at $COMBOS_JSON"
        return 1
    fi

    # Parse combos from JSON and create them
    # This is a simplified version - in production, use jq
    echo "Creating combos from $COMBOS_JSON..."

    # Create mega-free combo
    echo -n "Creating mega-free combo... "
    omniroute combo create mega-free --strategy priority \
        --model "aihorde/any" \
        --model "opencode/auto" \
        --model "huggingchat/auto" \
        --model "ollama-cloud/auto" \
        --model "zcode/auto" \
        --model "firecrawl/auto" \
        --model "searxng-search/auto" 2>&1 | grep -q "created\|already"
    print_success "mega-free created"

    # Create free-fallback combo
    echo -n "Creating free-fallback combo... "
    omniroute combo create free-fallback --strategy priority \
        --model "aihorde/any" \
        --model "ollama-cloud/auto" \
        --model "opencode/auto" \
        --model "huggingchat/auto" 2>&1 | grep -q "created\|already"
    print_success "free-fallback created"

    # Create no-auth-only combo
    echo -n "Creating no-auth-only combo... "
    omniroute combo create no-auth-only --strategy priority \
        --model "aihorde/any" \
        --model "opencode/auto" \
        --model "huggingchat/auto" 2>&1 | grep -q "created\|already"
    print_success "no-auth-only created"

    # Create round-robin-free combo
    echo -n "Creating round-robin-free combo... "
    omniroute combo create round-robin-free --strategy round-robin \
        --model "aihorde/any" \
        --model "opencode/auto" \
        --model "huggingchat/auto" \
        --model "ollama-cloud/auto" 2>&1 | grep -q "created\|already"
    print_success "round-robin-free created"

    # Create coding-focused combo
    echo -n "Creating coding-focused combo... "
    omniroute combo create coding-focused --strategy priority \
        --model "deepseek/deepseek-coder" \
        --model "mistral/codestral-latest" \
        --model "groq/llama-3.3-70b-versatile" \
        --model "nvidia/llama-3.1-70b-instruct" \
        --model "cerebras/llama3.1-70b" \
        --model "sambanova/llama-3.1-70b" \
        --model "gemini/gemini-2.0-flash" \
        --model "aihorde/any" 2>&1 | grep -q "created\|already"
    print_success "coding-focused created"

    # Create fast-inference combo
    echo -n "Creating fast-inference combo... "
    omniroute combo create fast-inference --strategy priority \
        --model "cerebras/llama3.1-8b" \
        --model "groq/llama-3.1-8b-instant" \
        --model "sambanova/llama-3.1-8b" \
        --model "nvidia/llama-3.1-8b-instruct" \
        --model "aihorde/any" 2>&1 | grep -q "created\|already"
    print_success "fast-inference created"

    # Create heavy-reasoning combo
    echo -n "Creating heavy-reasoning combo... "
    omniroute combo create heavy-reasoning --strategy priority \
        --model "deepseek/deepseek-reasoner" \
        --model "nvidia/llama-3.1-405b-instruct" \
        --model "gemini/gemini-1.5-pro" \
        --model "mistral/mistral-large-latest" \
        --model "cohere/command-r-plus" \
        --model "aihorde/any" 2>&1 | grep -q "created\|already"
    print_success "heavy-reasoning created"
}

# Test the setup
test_setup() {
    print_header "Testing Setup"

    echo "Testing mega-free combo..."
    omniroute simulate "Hello, this is a test" --combo mega-free --explain 2>&1 | tail -20

    echo ""
    print_success "Setup test complete!"
}

# Print summary
print_summary() {
    print_header "Setup Complete!"

    echo "Next steps:"
    echo ""
    echo "1. Add more API keys (if not done):"
    echo "   nano ~/.omniroute/api-keys.env"
    echo "   ./scripts/add-keys.sh"
    echo ""
    echo "2. Activate a combo:"
    echo "   omniroute combo switch mega-free"
    echo ""
    echo "3. Test the setup:"
    echo "   omniroute simulate 'Write a Python function' --combo mega-free --explain"
    echo ""
    echo "4. Use with your coding tools:"
    echo "   - Claude Code: Configure to use OmniRoute as proxy"
    echo "   - Codex: Set OMNIROUTE_BASE_URL=http://localhost:20128"
    echo "   - Any OpenAI-compatible tool: Point to http://localhost:20128/v1"
    echo ""
    echo "5. Manage combos:"
    echo "   ~/.omniroute/combos.sh list"
    echo "   ~/.omniroute/combos.sh switch <combo-name>"
    echo "   ~/.omniroute/combos.sh test <combo-name> 'your prompt'"
    echo ""
    echo "Documentation:"
    echo "   - API Keys Guide: docs/API_KEYS_GUIDE.md"
    echo "   - Combo Customization: docs/COMBO_CUSTOMIZATION.md"
    echo "   - Troubleshooting: docs/TROUBLESHOOTING.md"
    echo ""
    echo "Happy coding! 🚀"
}

# Main execution
main() {
    print_header "OmniRoute Free Token Maximizer — Setup"

    check_omniroute
    backup_config
    add_noauth_providers
    add_api_key_providers
    create_combos
    test_setup
    print_summary
}

# Run main function
main "$@"
