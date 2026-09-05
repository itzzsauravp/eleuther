#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# OmniRoute — OpenCode Agent Adapter
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

TARGET_DIR="$WORKSPACE_DIR/.opencode/rules"
mkdir -p "$TARGET_DIR"

# Inject rules into OpenCode rules directory
if [ -n "$BUNDLE_FILE" ] && [ -f "$BUNDLE_FILE" ]; then
    cp "$BUNDLE_FILE" "$TARGET_DIR/omniroute-rules.md"
    print_success "Installed OpenCode rules: .opencode/rules/omniroute-rules.md"
fi

print_info "OpenCode configured for role: ${ROLE:-default}"
