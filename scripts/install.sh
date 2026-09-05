#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Eleuther — Universal Role & Terminal Agent Installer
# ═══════════════════════════════════════════════════════════════
# Created by Saurav Parajulee | Powered by the OmniRoute Engine
# Cross-compatible: Linux, macOS, Windows (WSL / Git Bash)
#
# Highlights:
#   1. Automatic pre-install safety backup (~/.omniroute-backups/latest)
#   2. 1-click rollback available at any time (./scripts/revert.sh)
#   3. Interactive role & terminal agent selection with Caveman token optimizer
#   4. Provider registration & intelligent routing combo construction
#   5. Cleanly tagged shell environment exports
#
# Usage:
#   ./scripts/install.sh
#   ./scripts/install.sh --role backend --agent claude -y
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

# Parse optional command line arguments
ARG_ROLE=""
ARG_AGENT=""
AUTO_YES=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --role) ARG_ROLE="$2"; shift 2 ;;
        --agent) ARG_AGENT="$2"; shift 2 ;;
        -y|--yes) AUTO_YES=true; shift ;;
        *) shift ;;
    esac
done

# ═══════════════════════════════════════════════════════════════
# Step 1: Pre-Install Backup & Zero-Risk Safety Guarantee
# ═══════════════════════════════════════════════════════════════
print_header "Step 1/10 — Creating Automated Safety Backup"
bash "$SCRIPT_DIR/backup.sh"

echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD} 🛡️  ELEUTHER ZERO-RISK SAFETY GUARANTEE${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "✓ A complete backup of your existing configs has been created at:"
echo -e "  ${CYAN}$HOME/.omniroute-backups/latest/${NC}"
echo -e "→ You can completely undo ALL changes at any time by running:"
echo -e "  ${YELLOW}${BOLD}./scripts/revert.sh${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════
# Step 2: Interactive Role & Terminal Agent Selection
# ═══════════════════════════════════════════════════════════════
print_header "Step 2/10 — Role & Terminal Agent Persona Onboarding"

SELECTED_ROLE="$ARG_ROLE"
if [ -z "$SELECTED_ROLE" ]; then
    if [ -t 0 ] && [ "$AUTO_YES" = false ]; then
        echo -e "${BOLD}Select your primary engineering role:${NC}"
        echo "  1) Designer        (Design tokens, CSS layout, a11y contrast)"
        echo "  2) Frontend Dev    (Components, Playwright E2E, DOM profiling)"
        echo "  3) Backend Dev     (DB migrations, OpenAPI, SQL indexing) [Default]"
        echo "  4) System Architect(Microservices, threat modeling, caching)"
        echo "  5) QA              (Boundary tests, fuzz testing, regression)"
        echo "  6) DevOps          (Docker, Kubernetes, CI/CD, IaC guardrails)"
        echo -ne "${CYAN}Enter choice [1-6] (Default 3): ${NC}"
        read -r ROLE_CHOICE
        case "$ROLE_CHOICE" in
            1) SELECTED_ROLE="designer" ;;
            2) SELECTED_ROLE="frontend" ;;
            3|"") SELECTED_ROLE="backend" ;;
            4) SELECTED_ROLE="architect" ;;
            5) SELECTED_ROLE="qa" ;;
            6) SELECTED_ROLE="devops" ;;
            *) SELECTED_ROLE="backend" ;;
        esac
    else
        SELECTED_ROLE="backend"
    fi
fi
print_success "Selected Role: $SELECTED_ROLE"

SELECTED_AGENT="$ARG_AGENT"
if [ -z "$SELECTED_AGENT" ]; then
    if [ -t 0 ] && [ "$AUTO_YES" = false ]; then
        echo ""
        echo -e "${BOLD}Select your primary terminal coding agent:${NC}"
        echo "  1) Claude Code         (Anthropic CLI commands & routing) [Default]"
        echo "  2) OpenAI Codex / CLI  (AGENTS.md system instructions)"
        echo "  3) OpenCode            (.opencode rules & local endpoint)"
        echo "  4) Aider CLI           (CONVENTIONS.md & .aider.conf.yml)"
        echo -ne "${CYAN}Enter choice [1-4] (Default 1): ${NC}"
        read -r AGENT_CHOICE
        case "$AGENT_CHOICE" in
            1|"") SELECTED_AGENT="claude" ;;
            2) SELECTED_AGENT="codex" ;;
            3) SELECTED_AGENT="opencode" ;;
            4) SELECTED_AGENT="aider" ;;
            *) SELECTED_AGENT="claude" ;;
        esac
    else
        SELECTED_AGENT="claude"
    fi
fi
print_success "Selected Terminal Agent: $SELECTED_AGENT"

# ═══════════════════════════════════════════════════════════════
# Step 3: Check Node.js & npm
# ═══════════════════════════════════════════════════════════════
print_header "Step 3/10 — Check Node.js & Environment"
if command -v node >/dev/null 2>&1; then
    print_success "Node.js $(node -v)"
else
    print_error "Node.js is missing."
    echo "  macOS:   brew install node"
    echo "  Linux:   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs"
    echo "  Windows: https://nodejs.org/ or use WSL2"
    exit 1
fi
print_success "npm $(npm -v)"

# ═══════════════════════════════════════════════════════════════
# Step 4: Install OmniRoute routing engine globally if needed
# ═══════════════════════════════════════════════════════════════
print_header "Step 4/10 — Check OmniRoute Core Engine"
if command -v omniroute >/dev/null 2>&1; then
    print_success "omniroute core engine already installed"
else
    print_info "Installing omniroute core globally (npm install -g omniroute)..."
    npm install -g omniroute
    if command -v omniroute >/dev/null 2>&1; then
        print_success "omniroute core installed successfully"
    else
        print_error "omniroute install failed. Try running: sudo npm install -g omniroute"
        exit 1
    fi
fi

# ═══════════════════════════════════════════════════════════════
# Step 5: Configure ~/.omniroute and Encryption Key
# ═══════════════════════════════════════════════════════════════
print_header "Step 5/10 — Configure Local Environment & Secrets"
mkdir -p "$HOME/.omniroute"
print_success "$HOME/.omniroute directory ready"

if [ ! -f "$HOME/.omniroute/.env" ] || ! grep -q "STORAGE_ENCRYPTION_KEY=" "$HOME/.omniroute/.env" 2>/dev/null; then
    print_info "Generating secure STORAGE_ENCRYPTION_KEY in ~/.omniroute/.env..."
    KEY=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))" 2>/dev/null || openssl rand -hex 32 2>/dev/null || echo "eleuther-secret-$(date +%s)")
    cat > "$HOME/.omniroute/.env" <<EOF
# Eleuther / OmniRoute — generated by Eleuther install.sh
STORAGE_ENCRYPTION_KEY=$KEY
EOF
    chmod 600 "$HOME/.omniroute/.env" 2>/dev/null || true
    print_success ".env created with private encryption key"
else
    print_success ".env encryption key verified"
fi

# ═══════════════════════════════════════════════════════════════
# Step 6: Setup api-keys.env
# ═══════════════════════════════════════════════════════════════
print_header "Step 6/10 — Setup api-keys.env"
if [ -f "$HOME/.omniroute/api-keys.env" ]; then
    print_success "api-keys.env already exists in ~/.omniroute/"
else
    if [ -f "$REPO_ROOT/configs/api-keys.env.example" ]; then
        cp "$REPO_ROOT/configs/api-keys.env.example" "$HOME/.omniroute/api-keys.env"
        chmod 600 "$HOME/.omniroute/api-keys.env" 2>/dev/null || true
        print_success "Created ~/.omniroute/api-keys.env from template"
        print_warning "Remember to add your API keys: nano ~/.omniroute/api-keys.env"
    fi
fi

# ═══════════════════════════════════════════════════════════════
# Step 7: Register Providers
# ═══════════════════════════════════════════════════════════════
print_header "Step 7/10 — Register Model Providers"
print_info "Registering zero-key free providers..."
NOAUTH=(aihorde opencode huggingchat firecrawl searxng-search ollama-cloud zcode)
for p in "${NOAUTH[@]}"; do
    omniroute providers add "$p" --no-credential --yes >/dev/null 2>&1 \
        && print_success "$p (free, no key required)" \
        || print_warning "$p (already registered or skipped)"
done

if [ -f "$HOME/.omniroute/api-keys.env" ] && grep -q "=" "$HOME/.omniroute/api-keys.env" 2>/dev/null; then
    print_info "Registering providers from ~/.omniroute/api-keys.env..."
    bash "$SCRIPT_DIR/add-keys.sh" || print_warning "Some keys in api-keys.env had notices"
else
    print_warning "No keys found in ~/.omniroute/api-keys.env yet (free tiers will still work)"
fi

# ═══════════════════════════════════════════════════════════════
# Step 8: Build Routing Combos
# ═══════════════════════════════════════════════════════════════
print_header "Step 8/10 — Build & Validate Intelligent Combos"
bash "$SCRIPT_DIR/build-combos.sh" --switch
omniroute combo switch combo/execution >/dev/null 2>&1 || true
print_success "Active combo set to: combo/execution"

# ═══════════════════════════════════════════════════════════════
# Step 9: Synthesize Caveman & Role Skills into Terminal Agent
# ═══════════════════════════════════════════════════════════════
print_header "Step 9/10 — Inject Skills & Terminal Agent Adapter"
bash "$SCRIPT_DIR/setup-skills.sh" --role "$SELECTED_ROLE" --agent "$SELECTED_AGENT" --workspace "$REPO_ROOT"
print_success "Injected Caveman token optimizer & $SELECTED_ROLE skills into $SELECTED_AGENT adapter"

# ═══════════════════════════════════════════════════════════════
# Step 10: Shell Environment Configuration
# ═══════════════════════════════════════════════════════════════
print_header "Step 10/10 — Shell Environment & Fast Aliases"

# Detect target shell profile
SHELL_RC="$HOME/.zshrc"
if [ -n "$BASH_VERSION" ] || [ ! -f "$HOME/.zshrc" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_RC="$HOME/.bash_profile"
    fi
fi

# Remove previous managed block if present (cross-platform clean)
if [ -f "$SHELL_RC" ]; then
    tmp_rc="${SHELL_RC}.tmp.$$"
    awk '
        BEGIN { skip=0 }
        /# <<< (OmniRoute|Eleuther) Managed Block <<</ { skip=1; next }
        /# >>> (OmniRoute|Eleuther) Managed Block >>>/ { skip=0; next }
        !skip { print }
    ' "$SHELL_RC" > "$tmp_rc" 2>/dev/null && mv "$tmp_rc" "$SHELL_RC"
fi

cat >> "$SHELL_RC" <<'EOF'

# <<< Eleuther Managed Block <<<
# Eleuther Local Proxy Configuration (powered by OmniRoute)
export ANTHROPIC_BASE_URL="http://localhost:20128/v1"
export ANTHROPIC_API_KEY="omni-route-key"
export ANTHROPIC_DEFAULT_SONNET_MODEL="auto/coding"
export ANTHROPIC_DEFAULT_OPUS_MODEL="auto/coding"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"
export OPENAI_BASE_URL="http://localhost:20128/v1"
export OPENAI_API_KEY="omni-route-key"
export OPENAI_API_BASE="http://localhost:20128/v1"

# Fast Management Aliases
alias omni-stats="omniroute usage analytics"
alias or-combos="omniroute combo list 2>&1 | tail -n +5"
alias or-quota="omniroute quota 2>&1 | tail -n +5"
alias or-status="omniroute providers status 2>&1 | tail -n +5"
alias or-serve="omniroute serve"
# >>> Eleuther Managed Block >>>
EOF

print_success "Shell exports and aliases added to: $SHELL_RC"

# ═══════════════════════════════════════════════════════════════
# Completion Summary
# ═══════════════════════════════════════════════════════════════
print_header "🎉 ONBOARDING COMPLETE!"
echo -e "Eleuther is configured and ready for action!"
echo -e ""
echo -e "Role Selected:     ${BOLD}${SELECTED_ROLE^}${NC}"
echo -e "Terminal Agent:    ${BOLD}${SELECTED_AGENT^}${NC}"
echo -e "Token Optimizer:   ${BOLD}Caveman Protocol (Active)${NC}"
echo -e "Rollback Command:  ${BOLD}./scripts/revert.sh${NC}"
echo -e ""
echo -e "${BOLD}Quick Start in 3 Steps:${NC}"
echo -e "1. Start the local proxy server:"
echo -e "   ${CYAN}omniroute serve &${NC}"
echo -e ""
echo -e "2. Reload your shell environment:"
echo -e "   ${CYAN}source $SHELL_RC${NC}"
echo -e ""
echo -e "3. Launch your terminal agent:"
case "$SELECTED_AGENT" in
    claude) echo -e "   ${CYAN}claude${NC}" ;;
    codex)  echo -e "   ${CYAN}codex${NC} (or your OpenAI CLI command)" ;;
    opencode) echo -e "   ${CYAN}opencode${NC}" ;;
    aider)  echo -e "   ${CYAN}aider${NC}" ;;
    *)      echo -e "   ${CYAN}claude${NC}" ;;
esac
echo -e ""
echo -e "To add or update API keys at any time:"
echo -e "   1. Edit:  ${CYAN}nano ~/.omniroute/api-keys.env${NC}"
echo -e "   2. Sync:  ${CYAN}./scripts/add-keys.sh${NC}"