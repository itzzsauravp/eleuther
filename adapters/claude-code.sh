#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# OmniRoute — Claude Code Agent Adapter
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

TARGET_DIR="$WORKSPACE_DIR/.claude/commands"
mkdir -p "$TARGET_DIR"

# 1. Inject Caveman optimization command / protocol
if [ -n "$CAVEMAN_FILE" ] && [ -f "$CAVEMAN_FILE" ]; then
    cp "$CAVEMAN_FILE" "$TARGET_DIR/optimize.md"
    print_success "Installed Claude Code skill: .claude/commands/optimize.md"
fi

# 2. Inject Role Skills bundle
if [ -n "$BUNDLE_FILE" ] && [ -f "$BUNDLE_FILE" ]; then
    cp "$BUNDLE_FILE" "$TARGET_DIR/role-skills.md"
    print_success "Installed Claude Code role skills: .claude/commands/role-skills.md"
fi

print_info "Claude Code configured for role: ${ROLE:-default}"
