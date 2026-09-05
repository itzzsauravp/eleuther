#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# OmniRoute — OpenAI Codex & CLI Agent Adapter
# ═══════════════════════════════════════════════════════════════
set -e

GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_info()    { echo -e "${CYAN}→ $1${NC}"; }

WORKSPACE_DIR="$(pwd)"
ROLE=""
BUNDLE_FILE=""
CAVEMAN_FILE=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --workspace) WORKSPACE_DIR="$2"; shift 2 ;;
        --role) ROLE="$2"; shift 2 ;;
        --bundle) BUNDLE_FILE="$2"; shift 2 ;;
        --caveman) CAVEMAN_FILE="$2"; shift 2 ;;
        *) shift ;;
    esac
done

mkdir -p "$WORKSPACE_DIR"

# 1. Generate workspace AGENTS.md
if [ -n "$BUNDLE_FILE" ] && [ -f "$BUNDLE_FILE" ]; then
    cp "$BUNDLE_FILE" "$WORKSPACE_DIR/AGENTS.md"
    print_success "Installed Codex/CLI instructions: AGENTS.md"
fi

# 2. Also generate .codex/instructions.md
mkdir -p "$WORKSPACE_DIR/.codex"
if [ -n "$BUNDLE_FILE" ] && [ -f "$BUNDLE_FILE" ]; then
    cp "$BUNDLE_FILE" "$WORKSPACE_DIR/.codex/instructions.md"
    print_success "Installed Codex instructions: .codex/instructions.md"
fi

print_info "Codex/CLI configured for role: ${ROLE:-default}"
