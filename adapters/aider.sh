#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Eleuther — Aider Terminal Agent Adapter
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

# 1. Generate CONVENTIONS.md (natively read by Aider)
if [ -n "$BUNDLE_FILE" ] && [ -f "$BUNDLE_FILE" ]; then
    cp "$BUNDLE_FILE" "$WORKSPACE_DIR/CONVENTIONS.md"
    print_success "Installed Aider conventions: CONVENTIONS.md"
fi

# 2. Configure .aider.conf.yml if not already present
AIDER_CONF="$WORKSPACE_DIR/.aider.conf.yml"
if [ ! -f "$AIDER_CONF" ]; then
    cat > "$AIDER_CONF" <<'EOF'
# Eleuther Aider Configuration (OmniRoute Proxy)
openai-api-base: http://localhost:20128/v1
openai-api-key: omni-route-key
model: auto/coding
EOF
    print_success "Generated Aider configuration: .aider.conf.yml"
fi

print_info "Aider configured for role: ${ROLE:-default}"
