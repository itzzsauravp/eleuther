#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Eleuther — Universal Role & Terminal Agent Installer
# ═══════════════════════════════════════════════════════════════
# Created by Saurav Parajulee | Powered by the OmniRoute Engine
# Cross-compatible: Linux, macOS, Windows (WSL / Git Bash)
#
# Steps:
#   1. Safety backup (~/.eleuther-backups/latest)
#   2. Role & Terminal Agent selection
#   3. System requirements verification (Node.js, npm, npx, curl)
#   4. Global installation of OmniRoute and chosen coding agent CLI
#   5. Configure ~/.omniroute/.env with full encryption keys & settings
#   6. Scaffolding ~/.omniroute/api-keys.env template (no user registration)
#   7. Synthesize Role & Caveman skills + open-agent ecosystem skills
#   8. Tailor shell environment exports (.zshrc / .bashrc) with modular tagged blocks
#   9. "What To Do Next" onboarding guide (run register-keys.sh for providers)
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

# Parse CLI arguments
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
# Step 1: Pre-Install Safety Backup
# ═══════════════════════════════════════════════════════════════
print_header "Step 1/9 — Creating Automated Safety Backup"
bash "$SCRIPT_DIR/backup.sh" --all

# ═══════════════════════════════════════════════════════════════
# Step 2: Interactive Role & Terminal Agent Selection
# ═══════════════════════════════════════════════════════════════
print_header "Step 2/9 — Role & Terminal Agent Selection"

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
        echo -e "${BOLD}Select your terminal coding agent:${NC}"
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
# Step 3: Check System Environment
# ═══════════════════════════════════════════════════════════════
print_header "Step 3/9 — Check Node.js, npm & Tools"
if command -v node >/dev/null 2>&1; then
    print_success "Node.js $(node -v)"
else
    print_error "Node.js is missing. Please install Node.js (v18+ recommended):"
    echo "  macOS:   brew install node"
    echo "  Linux:   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs"
    echo "  Windows: https://nodejs.org/ or use WSL2"
    exit 1
fi

if command -v npm >/dev/null 2>&1; then
    print_success "npm $(npm -v)"
else
    print_error "npm is missing. Please ensure npm is installed with Node.js."
    exit 1
fi

# Ensure npm global bin directory is in PATH across all platforms (standard Node, nvm, fnm, brew, etc.)
NPM_GLOBAL_BIN="$(npm prefix -g 2>/dev/null)/bin"
if [ -n "$NPM_GLOBAL_BIN" ] && [ -d "$NPM_GLOBAL_BIN" ] && [[ ":$PATH:" != *":$NPM_GLOBAL_BIN:"* ]]; then
    export PATH="$NPM_GLOBAL_BIN:$PATH"
fi

# ═══════════════════════════════════════════════════════════════
# Step 4: Install OmniRoute Core Engine & Terminal Agent CLI
# ═══════════════════════════════════════════════════════════════
print_header "Step 4/9 — Check OmniRoute Core & Terminal Agents"

install_global_pkg() {
    local cmd_name="$1"
    local npm_pkg="$2"

    # Invalidate shell command cache (standard built-in in bash/zsh on all platforms)
    hash -r 2>/dev/null || true
    # Non-intrusive hook for environments with shims (mise/asdf), no-op on normal machines
    command -v mise >/dev/null 2>&1 && mise reshim 2>/dev/null || true
    command -v asdf >/dev/null 2>&1 && asdf reshim 2>/dev/null || true

    # Universal Check: verify the binary is installed AND actually executable
    if command -v "$cmd_name" >/dev/null 2>&1 && ("$cmd_name" --version >/dev/null 2>&1 || "$cmd_name" -v >/dev/null 2>&1 || "$cmd_name" --help >/dev/null 2>&1); then
        print_success "$cmd_name is already installed and functional."
        return 0
    fi

    # Fallback Check: does standard npm report it installed globally?
    if npm list -g --depth=0 "$npm_pkg" >/dev/null 2>&1; then
        local bin_dir="$(npm prefix -g 2>/dev/null)/bin"
        [ -d "$bin_dir" ] && export PATH="$bin_dir:$PATH"
        hash -r 2>/dev/null || true
        if command -v "$cmd_name" >/dev/null 2>&1; then
            print_success "$cmd_name is already installed."
            return 0
        fi
    fi

    print_info "Installing $cmd_name globally (npm install -g $npm_pkg)..."
    if npm install -g "$npm_pkg" >/dev/null 2>&1; then
        local bin_dir="$(npm prefix -g 2>/dev/null)/bin"
        [ -d "$bin_dir" ] && export PATH="$bin_dir:$PATH"
        hash -r 2>/dev/null || true
        command -v mise >/dev/null 2>&1 && mise reshim 2>/dev/null || true
        command -v asdf >/dev/null 2>&1 && asdf reshim 2>/dev/null || true

        if command -v "$cmd_name" >/dev/null 2>&1; then
            print_success "$cmd_name installed successfully."
            return 0
        fi
    fi

    print_warning "$cmd_name standard install failed or not in PATH. Trying with sudo..."
    if sudo npm install -g "$npm_pkg" >/dev/null 2>&1; then
        local bin_dir="$(npm prefix -g 2>/dev/null)/bin"
        [ -d "$bin_dir" ] && export PATH="$bin_dir:$PATH"
        hash -r 2>/dev/null || true
        command -v mise >/dev/null 2>&1 && mise reshim 2>/dev/null || true
        command -v asdf >/dev/null 2>&1 && asdf reshim 2>/dev/null || true
        print_success "$cmd_name installed successfully (sudo)."
    else
        print_warning "Could not auto-install $cmd_name. You can install it manually: npm install -g $npm_pkg"
    fi
}

# OmniRoute Core
install_global_pkg "omniroute" "omniroute"

# Selected Terminal Agent
case "$SELECTED_AGENT" in
    claude)
        install_global_pkg "claude" "@anthropic-ai/claude-code"
        ;;
    codex)
        install_global_pkg "codex" "@openai/codex"
        ;;
    opencode)
        install_global_pkg "opencode" "opencode-ai"
        ;;
    aider)
        if command -v aider >/dev/null 2>&1; then
            print_success "aider is already installed."
        else
            print_info "Checking python3 pip for aider-chat..."
            if command -v pip3 >/dev/null 2>&1 && pip3 install aider-chat >/dev/null 2>&1; then
                print_success "aider installed successfully via pip3."
            else
                install_global_pkg "aider" "aider-chat"
            fi
        fi
        ;;
esac

# ═══════════════════════════════════════════════════════════════
# Step 5: Configure ~/.omniroute and Encryption Key Secrets
# ═══════════════════════════════════════════════════════════════
print_header "Step 5/9 — Configure OmniRoute .env & Security Secrets"

mkdir -p "$HOME/.omniroute"
OMNI_ENV="$HOME/.omniroute/.env"

gen_hex_secret() {
    local bytes="$1"
    node -e "console.log(require('crypto').randomBytes($bytes).toString('hex'))" 2>/dev/null \
        || openssl rand -hex "$bytes" 2>/dev/null \
        || echo "eleuther-$RANDOM-$(date +%s)"
}

gen_base64_secret() {
    local bytes="$1"
    node -e "console.log(require('crypto').randomBytes($bytes).toString('base64'))" 2>/dev/null \
        || openssl rand -base64 "$bytes" 2>/dev/null \
        || echo "eleuther-$RANDOM-$(date +%s)"
}

if [ ! -f "$OMNI_ENV" ]; then
    print_info "Generating complete ~/.omniroute/.env security configuration..."
    ENC_KEY=$(gen_hex_secret 32)
    JWT_SEC=$(gen_base64_secret 48)
    API_SEC=$(gen_hex_secret 32)

    cat > "$OMNI_ENV" <<EOF
# ═══════════════════════════════════════════════════════════════
# Eleuther / OmniRoute Runtime Environment
# ═══════════════════════════════════════════════════════════════

# Security & Secrets
STORAGE_ENCRYPTION_KEY=$ENC_KEY
STORAGE_ENCRYPTION_KEY_VERSION=v1
JWT_SECRET=$JWT_SEC
API_KEY_SECRET=$API_SEC

# Dashboard / Admin Password
# Default is CHANGEME — uncomment and set your own password to secure the dashboard
# INITIAL_PASSWORD=CHANGEME

# Network & Server Port
PORT=20128
DASHBOARD_PORT=20128

# Proxy Access Control
# false allows local coding agents (claude, codex, aider) to route without proxy tokens
REQUIRE_API_KEY=false
NODE_ENV=production
EOF
    chmod 600 "$OMNI_ENV" 2>/dev/null || true
    print_success "Created ~/.omniroute/.env with full encryption secrets & proxy authorization"
else
    print_info "Checking existing ~/.omniroute/.env for missing required secrets..."

    if ! grep -q "STORAGE_ENCRYPTION_KEY=" "$OMNI_ENV" 2>/dev/null; then
        echo "STORAGE_ENCRYPTION_KEY=$(gen_hex_secret 32)" >> "$OMNI_ENV"
        echo "STORAGE_ENCRYPTION_KEY_VERSION=v1" >> "$OMNI_ENV"
    fi
    if ! grep -q "JWT_SECRET=" "$OMNI_ENV" 2>/dev/null; then
        echo "JWT_SECRET=$(gen_base64_secret 48)" >> "$OMNI_ENV"
    fi
    if ! grep -q "API_KEY_SECRET=" "$OMNI_ENV" 2>/dev/null; then
        echo "API_KEY_SECRET=$(gen_hex_secret 32)" >> "$OMNI_ENV"
    fi
    # INITIAL_PASSWORD: if missing entirely, add the commented default so user knows it exists
    if ! grep -q "INITIAL_PASSWORD" "$OMNI_ENV" 2>/dev/null; then
        echo "# Dashboard / Admin Password — uncomment and set your own to secure the dashboard" >> "$OMNI_ENV"
        echo "# INITIAL_PASSWORD=CHANGEME" >> "$OMNI_ENV"
    fi
    if ! grep -q "REQUIRE_API_KEY=" "$OMNI_ENV" 2>/dev/null; then
        echo "REQUIRE_API_KEY=false" >> "$OMNI_ENV"
    fi
    if ! grep -q "PORT=" "$OMNI_ENV" 2>/dev/null; then
        echo "PORT=20128" >> "$OMNI_ENV"
    fi

    chmod 600 "$OMNI_ENV" 2>/dev/null || true
    print_success "~/.omniroute/.env verified and updated"
fi

# ═══════════════════════════════════════════════════════════════
# Step 6: Setup api-keys.env Template (No Registration Yet)
# ═══════════════════════════════════════════════════════════════
print_header "Step 6/9 — Prepare api-keys.env Template"

KEYS_ENV="$HOME/.omniroute/api-keys.env"
if [ -f "$KEYS_ENV" ]; then
    print_success "api-keys.env already exists at $KEYS_ENV"
else
    if [ -f "$REPO_ROOT/configs/api-keys.env.example" ]; then
        cp "$REPO_ROOT/configs/api-keys.env.example" "$KEYS_ENV"
        chmod 600 "$KEYS_ENV" 2>/dev/null || true
        print_success "Created template at: $KEYS_ENV"
    fi
fi
print_info "Note: User API keys are NOT registered during installation."
print_info "Run ./scripts/register-keys.sh to register keys AND free no-auth providers."

# ═══════════════════════════════════════════════════════════════
# Step 7: Inject Skills & Terminal Agent Adapter
# (formerly Step 9 — re-numbered after removing no-auth from install)
# ═══════════════════════════════════════════════════════════════

print_header "Step 7/9 — Inject Skills & Agent Adapters"

bash "$SCRIPT_DIR/setup-skills.sh" \
    --role "$SELECTED_ROLE" \
    --agent "$SELECTED_AGENT" \
    --workspace "$REPO_ROOT" \
    --ecosystem

print_success "Configured Caveman optimizer, $SELECTED_ROLE persona, and agent skills"

# ═══════════════════════════════════════════════════════════════
# Step 8: Shell Environment Configuration (Modular Tagged Blocks)
# ═══════════════════════════════════════════════════════════════
print_header "Step 8/9 — Shell Environment & Tailored Exports"

# Detect shell profile compatible with macOS and all Linux distributions
SHELL_RC="$HOME/.zshrc"
if [[ "$OSTYPE" == "darwin"* ]] || [ "$(uname 2>/dev/null)" = "Darwin" ]; then
    # macOS defaults to zsh (~/.zshrc); create it if missing
    SHELL_RC="$HOME/.zshrc"
    [ ! -f "$SHELL_RC" ] && touch "$SHELL_RC" 2>/dev/null || true
else
    # Linux / other environments: respect user $SHELL and existing profile files
    if [[ "$SHELL" == */zsh ]]; then
        SHELL_RC="$HOME/.zshrc"
        [ ! -f "$SHELL_RC" ] && touch "$SHELL_RC" 2>/dev/null || true
    elif [[ "$SHELL" == */bash ]]; then
        if [ -f "$HOME/.bashrc" ]; then
            SHELL_RC="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_RC="$HOME/.bash_profile"
        else
            SHELL_RC="$HOME/.bashrc"
            touch "$SHELL_RC" 2>/dev/null || true
        fi
    else
        # Generic fallback for Linux / other shells
        if [ -f "$HOME/.zshrc" ]; then
            SHELL_RC="$HOME/.zshrc"
        elif [ -f "$HOME/.bashrc" ]; then
            SHELL_RC="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_RC="$HOME/.bash_profile"
        else
            SHELL_RC="$HOME/.bashrc"
            touch "$SHELL_RC" 2>/dev/null || true
        fi
    fi
fi

# Clean prior monolithic block or untagged legacy aliases if present
if [ -f "$SHELL_RC" ]; then
    tmp_rc="${SHELL_RC}.tmp.$$"
    awk '
        BEGIN { skip=0 }
        /# <<< (OmniRoute|Eleuther) Managed Block <<</ { skip=1; next }
        /# >>> (OmniRoute|Eleuther) Managed Block >>>/ { skip=0; next }
        /# ── OmniRoute noise-filtered aliases/ { skip=1; next }
        skip && /^alias or-/ { next }
        !skip { print }
    ' "$SHELL_RC" > "$tmp_rc" 2>/dev/null && mv "$tmp_rc" "$SHELL_RC"
fi

# Helper function to remove a specific tagged block from shell RC
clean_tagged_block() {
    local target_tag="$1"
    [ ! -f "$SHELL_RC" ] && return 0
    local tmp_rc="${SHELL_RC}.tmp.$$"
    awk -v tag="$target_tag" '
        BEGIN { skip=0 }
        $0 ~ "# <<< Eleuther: " tag " <<<" { skip=1; next }
        $0 ~ "# >>> Eleuther: " tag " >>>" { skip=0; next }
        !skip { print }
    ' "$SHELL_RC" > "$tmp_rc" 2>/dev/null && mv "$tmp_rc" "$SHELL_RC"
}

# 1. Update Telemetry & Monitoring Aliases (Noise-Filtered)
clean_tagged_block "Telemetry"
cat >> "$SHELL_RC" <<'EOF'

# <<< Eleuther: Telemetry <<<
# OmniRoute Monitoring & Telemetry (Noise-Filtered)
alias or-serve="omniroute serve"
alias or-combos="omniroute combo list 2>&1 | tail -n +5"
alias or-usage="omniroute usage analytics 2>&1 | tail -n +5"
alias or-util="omniroute usage utilization 2>&1 | tail -n +5"
alias or-logs="omniroute usage logs 2>&1 | tail -n +5"
alias or-quota="omniroute quota 2>&1 | tail -n +5"
alias or-telemetry="omniroute telemetry 2>&1 | tail -n +5"
alias or-cost="omniroute cost 2>&1 | tail -n +5"
alias or-status="omniroute providers status 2>&1 | tail -n +5"
alias or-metrics="omniroute providers metrics 2>&1 | tail -n +5"
# >>> Eleuther: Telemetry >>>
EOF

# 2. Update Agent-Specific Variables
clean_tagged_block "Agent $SELECTED_AGENT"

case "$SELECTED_AGENT" in
    claude)
        cat >> "$SHELL_RC" <<'EOF'

# <<< Eleuther: Agent claude <<<
# Claude Code Local Proxy Configuration
export ANTHROPIC_BASE_URL="http://localhost:20128/v1"
export ANTHROPIC_API_KEY="omni-route-key"
export ANTHROPIC_DEFAULT_SONNET_MODEL="auto/coding"
export ANTHROPIC_DEFAULT_OPUS_MODEL="auto/coding"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="1"
# >>> Eleuther: Agent claude >>>
EOF
        ;;
    codex)
        cat >> "$SHELL_RC" <<'EOF'

# <<< Eleuther: Agent codex <<<
# OpenAI Codex / CLI Local Proxy Configuration
export OPENAI_BASE_URL="http://localhost:20128/v1"
export OPENAI_API_BASE="http://localhost:20128/v1"
export OPENAI_API_KEY="omni-route-key"
# >>> Eleuther: Agent codex >>>
EOF
        ;;
    opencode)
        cat >> "$SHELL_RC" <<'EOF'

# <<< Eleuther: Agent opencode <<<
# OpenCode Local Proxy Configuration
export OPENCODE_API_BASE="http://localhost:20128/v1"
export OPENAI_BASE_URL="http://localhost:20128/v1"
export OPENAI_API_KEY="omni-route-key"
# >>> Eleuther: Agent opencode >>>
EOF
        ;;
    aider)
        cat >> "$SHELL_RC" <<'EOF'

# <<< Eleuther: Agent aider <<<
# Aider CLI Local Proxy Configuration
export OPENAI_API_BASE="http://localhost:20128/v1"
export OPENAI_API_KEY="omni-route-key"
export AIDER_MODEL="openai/auto/coding"
export AIDER_OPENAI_API_BASE="http://localhost:20128/v1"
# >>> Eleuther: Agent aider >>>
EOF
        ;;
esac

print_success "Tagged shell exports and noise-filtered telemetry aliases added to: $SHELL_RC"

# ═══════════════════════════════════════════════════════════════
# Completion & What To Do Next
# ═══════════════════════════════════════════════════════════════
print_header "Step 9/9 — Provider Registration & What To Do Next"

echo -e "Selected Role:   ${BOLD}${SELECTED_ROLE^}${NC}"
echo -e "Terminal Agent:  ${BOLD}${SELECTED_AGENT^}${NC}"
echo -e "Safety Backup:   ${BOLD}~/.eleuther-backups/latest/${NC}"
echo ""

# Ask user to run server before registering providers
echo -e "${BOLD}${CYAN}───────────────────────────────────────────────────────────────${NC}"
echo -e "${BOLD}OmniRoute Local Server Setup${NC}"
echo -e "OmniRoute requires its server daemon to be running before registering providers."
echo -e "${BOLD}${CYAN}───────────────────────────────────────────────────────────────${NC}"
if ! omniroute health >/dev/null 2>&1; then
    echo ""
    read -rp "Would you like to start the OmniRoute background server now? [Y/n]: " START_SERVER_CHOICE
    START_SERVER_CHOICE="${START_SERVER_CHOICE:-Y}"
    if [[ "$START_SERVER_CHOICE" =~ ^[Yy]$ ]]; then
        print_info "Starting OmniRoute daemon (omniroute serve --daemon)..."
        omniroute serve --daemon >/dev/null 2>&1 || true
        SERVER_READY=0
        for _ in {1..15}; do
            if omniroute health >/dev/null 2>&1; then
                SERVER_READY=1
                break
            fi
            sleep 1
        done
        if [ "$SERVER_READY" -eq 1 ]; then
            print_success "OmniRoute background server is running and ready!"
        else
            print_warning "Server starting in background. Verify with: omniroute health"
        fi
    else
        print_warning "Skipped starting server. Please run '${CYAN}omniroute serve --daemon${NC}' before registering keys!"
    fi
else
    print_success "OmniRoute background server is already running."
fi
echo ""

echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN} 🎉 INSTALLATION COMPLETE — WHAT TO DO NEXT${NC}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}1. Ensure OmniRoute Local Server is Running:${NC}"
echo -e "   ${CYAN}omniroute serve --daemon${NC}"
echo -e "   (The local proxy server must be active to register providers and route requests)"
echo ""
echo -e "${BOLD}2. (Optional) Add Your API Keys for More Providers:${NC}"
echo -e "   Open:  ${CYAN}nano ~/.omniroute/api-keys.env${NC}"
echo -e "   Paste any keys you have (Gemini, Groq, DeepSeek, OpenRouter, etc.) and save."
echo ""
echo -e "${BOLD}3. Register Free Providers + Your API Keys:${NC}"
echo -e "   ${CYAN}./scripts/register-keys.sh${NC}"
echo -e "   This will:"
echo -e "     • Register ALL free/no-auth providers automatically (Pollinations, Cloudflare, etc.)"
echo -e "     • Register any API keys you've added to ~/.omniroute/api-keys.env"
echo -e "     • Build intelligent failover routing combos across all providers"
echo ""
echo -e "${BOLD}4. Reload Your Shell Profile:${NC}"
echo -e "   ${CYAN}source $SHELL_RC${NC}"
echo ""
echo -e "${BOLD}5. Launch Your Terminal Coding Agent:${NC}"
case "$SELECTED_AGENT" in
    claude) echo -e "   ${CYAN}claude${NC}" ;;
    codex)  echo -e "   ${CYAN}codex${NC}" ;;
    opencode) echo -e "   ${CYAN}opencode${NC}" ;;
    aider)  echo -e "   ${CYAN}aider${NC}" ;;
esac
echo ""
echo -e "${BOLD}6. Monitor Routes & Telemetry Anytime:${NC}"
echo -e "   Check active combos:    ${CYAN}or-combos${NC}"
echo -e "   Live model status:      ${CYAN}or-status${NC}"
echo -e "   Token quota & budget:   ${CYAN}or-quota${NC}"
echo -e "   Usage analytics:        ${CYAN}or-usage${NC}"
echo ""
echo -e "${BOLD}🛡️  Safety Reminder — Keep Backups of Your Settings:${NC}"
echo -e "   Before changing roles, reconfiguring agents, or updating keys,"
echo -e "   always snapshot your entire environment with:"
echo -e "     ${CYAN}./scripts/backup.sh${NC}"
echo -e "   Backups are safely preserved in: ${BOLD}~/.eleuther-backups/${NC}"
echo -e "   To clean up or rollback anytime: ${CYAN}./scripts/uninstall.sh${NC}"
echo ""
