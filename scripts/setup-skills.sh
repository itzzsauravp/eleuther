#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Eleuther — Terminal Agent Skill Synthesizer & Adapter Injector
# ═══════════════════════════════════════════════════════════════
# Usage:
#   ./scripts/setup-skills.sh --role <role> --agent <agent> [--workspace <path>]
#
# Roles:
#   designer | frontend | backend | architect | qa | devops
# Terminal Agents:
#   claude | codex | opencode | aider | all
# ═══════════════════════════════════════════════════════════════

set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error()   { echo -e "${RED}✖ $1${NC}"; }
print_info()    { echo -e "${CYAN}→ $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ROLE=""
AGENT=""
WORKSPACE="$(pwd)"

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --role) ROLE="$2"; shift 2 ;;
        --agent) AGENT="$2"; shift 2 ;;
        --workspace) WORKSPACE="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Normalize role names
case "$ROLE" in
    1|designer|Designer) ROLE="designer" ;;
    2|frontend|Frontend|"Frontend Dev") ROLE="frontend" ;;
    3|backend|Backend|"Backend Dev") ROLE="backend" ;;
    4|architect|Architect|"System Architect") ROLE="architect" ;;
    5|qa|QA) ROLE="qa" ;;
    6|devops|DevOps) ROLE="devops" ;;
    *) ROLE="backend" ;;
esac

# Normalize terminal agent names
case "$AGENT" in
    1|claude|claude-code|"Claude Code") AGENT="claude" ;;
    2|codex|Codex|"OpenAI Codex"|"OpenAI Codex / CLI") AGENT="codex" ;;
    3|opencode|OpenCode) AGENT="opencode" ;;
    4|aider|Aider|"Aider CLI") AGENT="aider" ;;
    all|All) AGENT="all" ;;
    *) AGENT="claude" ;;
esac

print_info "Synthesizing skills for Role: [${ROLE}] -> Terminal Agent: [${AGENT}]"

SKILLS_DIR="$REPO_ROOT/skills"
CAVEMAN_FILE="$SKILLS_DIR/core/caveman.md"
GIT_FILE="$SKILLS_DIR/core/git-commits.md"
SECURITY_FILE="$SKILLS_DIR/core/security-linter.md"
ROLE_FILE="$SKILLS_DIR/roles/${ROLE}.md"

# Build combined bundle
TMP_BUNDLE="/tmp/eleuther-bundle-$$.md"
mkdir -p "$HOME/.omniroute"
ACTIVE_BUNDLE="$HOME/.omniroute/active-role-skills.md"

{
    echo "# Eleuther Agent Persona & Operational Guidelines"
    echo ""
    echo "> Active Role: ${ROLE^}"
    echo "> Built with Eleuther Multi-Agent Architecture powered by OmniRoute"
    echo "> Optimized with Caveman Protocol for maximum token efficiency"
    echo ""
    echo "---"
    echo ""
    [ -f "$CAVEMAN_FILE" ] && cat "$CAVEMAN_FILE" && echo -e "\n---\n"
    [ -f "$GIT_FILE" ] && cat "$GIT_FILE" && echo -e "\n---\n"
    [ -f "$SECURITY_FILE" ] && cat "$SECURITY_FILE" && echo -e "\n---\n"
    [ -f "$ROLE_FILE" ] && cat "$ROLE_FILE"
} > "$TMP_BUNDLE"

cp "$TMP_BUNDLE" "$ACTIVE_BUNDLE"
rm -f "$TMP_BUNDLE"

# Dispatch to adapters
run_adapter() {
    local target="$1"
    local adapter_script="$REPO_ROOT/adapters/${target}.sh"

    if [ "$target" = "claude" ]; then
        adapter_script="$REPO_ROOT/adapters/claude-code.sh"
    fi

    if [ -f "$adapter_script" ]; then
        bash "$adapter_script" \
            --workspace "$WORKSPACE" \
            --role "$ROLE" \
            --bundle "$ACTIVE_BUNDLE" \
            --caveman "$CAVEMAN_FILE"
    else
        print_warning "Adapter script not found: $adapter_script"
    fi
}

if [ "$AGENT" = "all" ]; then
    run_adapter "claude"
    run_adapter "codex"
    run_adapter "opencode"
    run_adapter "aider"
else
    run_adapter "$AGENT"
fi

print_success "Skill synthesis and adapter configuration complete!"
