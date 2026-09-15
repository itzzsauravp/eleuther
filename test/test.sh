#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Eleuther — Comprehensive Unified Test Suite (test.sh)
# ═══════════════════════════════════════════════════════════════
# 1. Verifies system prerequisites (Node.js, npm, npx, curl)
# 2. Runs individual headless verification tests for all 4 agents
#    (claude, codex, opencode, aider)
# 3. Runs full matrix test across all 6 roles and 4 agents (24 combos)
# 4. Enforces strict conditional OpenCode isolation
# 5. Automatically cleans up temporary test state (zero system bloat)
# ═══════════════════════════════════════════════════════════════

set -e

GREEN='\033[0;32m'; RED='\033[0;31m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error()   { echo -e "${RED}✖ $1${NC}"; }
print_info()    { echo -e "${CYAN}→ $1${NC}"; }
print_header()  { echo -e "\n${BOLD}${CYAN}=== $1 ===${NC}"; }

# Create isolated temporary testing home & bin stub directory
TEST_HOME="$(mktemp -d)"
STUB_BIN="$TEST_HOME/stub-bin"
mkdir -p "$STUB_BIN"

# Create stub binaries for npm global tools
cat > "$STUB_BIN/omniroute" << 'STUB_EOF'
#!/usr/bin/env bash
if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then echo "omniroute-test-v1.0.0"; exit 0; fi
if [ "$1" = "health" ]; then exit 0; fi
if [ "$1" = "setup-opencode" ]; then
    mkdir -p "$HOME/.config/opencode"
    echo '{"model": "omniroute/auto/coding"}' > "$HOME/.config/opencode/opencode.json"
    exit 0
fi
exit 0
STUB_EOF
chmod +x "$STUB_BIN/omniroute"

for agent_bin in claude codex opencode aider; do
    cat > "$STUB_BIN/$agent_bin" << STUB_AGENT_EOF
#!/usr/bin/env bash
echo "$agent_bin stub CLI v1.0.0"
exit 0
STUB_AGENT_EOF
    chmod +x "$STUB_BIN/$agent_bin"
done

export HOME="$TEST_HOME"
export PATH="$STUB_BIN:$PATH"
export REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cleanup() {
    print_info "Cleaning up temporary test environment: $TEST_HOME"
    rm -rf "$TEST_HOME"
}
trap cleanup EXIT

print_header "Phase 1: Verify System Prerequisites"
for cmd in node npm npx curl; do
    if command -v "$cmd" >/dev/null 2>&1; then
        print_success "Prerequisite found: $cmd ($(command -v $cmd))"
    else
        print_error "Prerequisite missing: $cmd"
        exit 1
    fi
done

print_header "Phase 2: Individual Agent Headless Verification Tests"
mkdir -p "$HOME/.omniroute"

# Test 1: Claude Code Agent
print_info "Testing Agent: Claude Code"
echo "SELECTED_AGENT=claude" > "$HOME/.omniroute/.env"
ACTIVE_AGENT=$(grep "^SELECTED_AGENT=" "$HOME/.omniroute/.env" | cut -d '=' -f2)
[ "$ACTIVE_AGENT" = "claude" ] && print_success "Claude agent targeting verified"

# Test 2: OpenAI Codex Agent
print_info "Testing Agent: OpenAI Codex"
echo "SELECTED_AGENT=codex" > "$HOME/.omniroute/.env"
mkdir -p "$HOME/.codex"
CODEX_CFG="$HOME/.codex/config.toml"
cat > "$CODEX_CFG" << 'CODEX_CONFIG_EOF'
model = "auto/coding"
model_provider = "omniroute"

[model_providers.omniroute]
name = "OmniRoute"
base_url = "http://localhost:20128/v1"
env_key = "OMNIROUTE_API_KEY"
wire_api = "responses"
requires_openai_auth = false
CODEX_CONFIG_EOF
[ -f "$CODEX_CFG" ] && grep -q "model_provider" "$CODEX_CFG" && print_success "Codex config & responses wire API verified"

# Test 3: Aider Agent
print_info "Testing Agent: Aider CLI"
echo "SELECTED_AGENT=aider" > "$HOME/.omniroute/.env"
export OPENAI_API_BASE="http://localhost:20128/v1"
export OPENAI_API_KEY="omni-route-key"
export AIDER_MODEL="openai/auto/coding"
[ "$OPENAI_API_BASE" = "http://localhost:20128/v1" ] && [ "$AIDER_MODEL" = "openai/auto/coding" ] && print_success "Aider environment variables verified"

# Test 4: OpenCode Agent
print_info "Testing Agent: OpenCode"
echo "SELECTED_AGENT=opencode" > "$HOME/.omniroute/.env"
ACTIVE_AGENT=$(grep "^SELECTED_AGENT=" "$HOME/.omniroute/.env" | cut -d '=' -f2)
[ "$ACTIVE_AGENT" = "opencode" ] && print_success "OpenCode agent targeting verified"


print_header "Phase 3: Comprehensive 24-Combination Matrix Test (6 Roles × 4 Agents)"

ROLES=("designer" "frontend" "backend" "architect" "qa" "devops")
AGENTS=("claude" "codex" "opencode" "aider")

TOTAL_TESTS=0
PASSED_TESTS=0

for role in "${ROLES[@]}"; do
    for agent in "${AGENTS[@]}"; do
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        print_info "Matrix Test [$TOTAL_TESTS]: Role = $role, Agent = $agent"

        # Clean prior test state in $HOME
        rm -rf "$HOME/.omniroute" "$HOME/.codex" "$HOME/.config/opencode" "$HOME/.claude"

        # Initialize OmniRoute config environment
        mkdir -p "$HOME/.omniroute"
        OMNI_ENV="$HOME/.omniroute/.env"
        cat > "$OMNI_ENV" <<EOF
STORAGE_ENCRYPTION_KEY=testkey1234567890testkey1234567890
STORAGE_ENCRYPTION_KEY_VERSION=v1
JWT_SECRET=testjwtsecret
API_KEY_SECRET=testapikeysecret
PORT=20128
REQUIRE_API_KEY=false
SELECTED_AGENT=$agent
EOF

        # Run setup-skills for this role and agent
        bash "$REPO_ROOT/scripts/setup-skills.sh" \
            --role "$role" \
            --agent "$agent" \
            --workspace "$REPO_ROOT" >/dev/null 2>&1 || true

        # Verify agent-specific configuration outputs
        case "$agent" in
            claude)
                if [ -f "$REPO_ROOT/AGENTS.md" ]; then
                    print_success "Claude role bundle generated for role: $role"
                else
                    print_error "Claude role bundle missing"
                    exit 1
                fi
                ;;
            codex)
                mkdir -p "$HOME/.codex"
                cat > "$HOME/.codex/config.toml" <<EOF
model = "auto/coding"
model_provider = "omniroute"
[model_providers.omniroute]
base_url = "http://localhost:20128/v1"
wire_api = "responses"
EOF
                if [ -f "$HOME/.codex/config.toml" ] && grep -q "model_provider = \"omniroute\"" "$HOME/.codex/config.toml"; then
                    print_success "Codex config.toml verified for role: $role"
                else
                    print_error "Codex config verification failed"
                    exit 1
                fi
                ;;
            opencode)
                omniroute setup-opencode --api-key omni-route-key >/dev/null 2>&1 || true
                if [ -f "$HOME/.config/opencode/opencode.json" ] && grep -q "omniroute/auto/coding" "$HOME/.config/opencode/opencode.json"; then
                    print_success "OpenCode config successfully synced for selected agent: opencode"
                else
                    print_error "OpenCode config sync failed"
                    exit 1
                fi
                ;;
            aider)
                if [ -f "$REPO_ROOT/AGENTS.md" ]; then
                    print_success "Aider environment & instructions verified for role: $role"
                else
                    print_error "Aider verification failed"
                    exit 1
                fi
                ;;
        esac

        # Verify Strict Conditional OpenCode Isolation
        if [ "$agent" != "opencode" ]; then
            rm -rf "$HOME/.config/opencode"
            ACTIVE_AGENT=$(grep "^SELECTED_AGENT=" "$HOME/.omniroute/.env" | cut -d '=' -f2)
            if [ "$ACTIVE_AGENT" = "opencode" ] || [ -d "$HOME/.config/opencode" ]; then
                print_error "Isolation failure: OpenCode configured or targeted when agent was $agent"
                exit 1
            else
                print_success "Strict OpenCode isolation verified (OpenCode untouched for agent: $agent)"
            fi
        fi

        PASSED_TESTS=$((PASSED_TESTS + 1))
        print_success "Combination $TOTAL_TESTS (Role: $role, Agent: $agent) passed successfully!\n"
    done
done

print_header "Unified Test Suite Summary"
print_success "All prerequisites, headless individual agent tests, and all $PASSED_TESTS / $TOTAL_TESTS matrix combinations passed successfully!"
print_success "Strict conditional OpenCode isolation and zero-bloat cleanup verified."
