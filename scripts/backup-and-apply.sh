#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# OmniRoute — Backup & Apply Settings Script
# ═══════════════════════════════════════════════════════════════
# This script:
#   1. Backs up existing ~/.omniroute to ~/.omniroute.bak (and timestamped backup)
#   2. Ensures api-keys.env and .env are preserved
#   3. Re-registers API key providers & no-auth providers
#   4. Re-builds and switches routing combos using build-combos.sh
#
# Run: ./scripts/backup-and-apply.sh
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

OMNI_DIR="$HOME/.omniroute"
BACKUP_DIR="$HOME/.omniroute.bak"
TIMESTAMP_BACKUP="$HOME/.omniroute.bak.$(date +%Y%m%d_%H%M%S)"

print_header "Step 1/4 — Backing up existing ~/.omniroute configuration"
if [ -d "$OMNI_DIR" ]; then
    if [ -d "$BACKUP_DIR" ]; then
        rm -rf "$BACKUP_DIR"
    fi
    cp -r "$OMNI_DIR" "$BACKUP_DIR"
    cp -r "$OMNI_DIR" "$TIMESTAMP_BACKUP"
    print_success "Backed up $OMNI_DIR to $BACKUP_DIR"
    print_success "Created timestamped backup at $TIMESTAMP_BACKUP"
else
    print_warning "$OMNI_DIR does not exist yet. Nothing to back up."
    mkdir -p "$OMNI_DIR"
fi

print_header "Step 2/4 — Ensuring config files and API keys are intact"
if [ ! -f "$OMNI_DIR/.env" ]; then
    if [ -f "$BACKUP_DIR/.env" ]; then
        cp "$BACKUP_DIR/.env" "$OMNI_DIR/.env"
        print_success "Restored .env from backup"
    else
        print_info "Generating new STORAGE_ENCRYPTION_KEY in .env..."
        KEY=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))" 2>/dev/null || openssl rand -hex 32)
        cat > "$OMNI_DIR/.env" <<EOF
STORAGE_ENCRYPTION_KEY=$KEY
EOF
        chmod 600 "$OMNI_DIR/.env"
        print_success "Created new .env"
    fi
else
    print_success ".env exists"
fi

if [ ! -f "$OMNI_DIR/api-keys.env" ]; then
    if [ -f "$BACKUP_DIR/api-keys.env" ]; then
        cp "$BACKUP_DIR/api-keys.env" "$OMNI_DIR/api-keys.env"
        print_success "Restored api-keys.env from backup"
    elif [ -f "configs/api-keys.env.example" ]; then
        cp "configs/api-keys.env.example" "$OMNI_DIR/api-keys.env"
        chmod 600 "$OMNI_DIR/api-keys.env"
        print_warning "Created api-keys.env from template. Add your keys in nano ~/.omniroute/api-keys.env"
    fi
else
    print_success "api-keys.env exists"
fi

print_header "Step 3/4 — Re-registering providers & API keys"
NOAUTH=(aihorde opencode huggingchat firecrawl searxng-search ollama-cloud zcode)
for p in "${NOAUTH[@]}"; do
    omniroute providers add "$p" --no-credential --yes >/dev/null 2>&1 \
        && print_success "$p (no-auth)" \
        || true
done

if [ -f "$OMNI_DIR/api-keys.env" ] && grep -q "=" "$OMNI_DIR/api-keys.env" 2>/dev/null; then
    bash "$(dirname "$0")/add-keys.sh" || print_warning "Some API keys registration had warnings"
else
    print_warning "api-keys.env is empty or missing API keys."
fi

print_header "Step 4/4 — Rebuilding and switching routing combos"
bash "$(dirname "$0")/build-combos.sh" --switch

print_header "🎉 Backup and Apply Complete!"
echo "Your previous settings were safely backed up to:"
echo "  - $BACKUP_DIR"
echo "  - $TIMESTAMP_BACKUP"
echo ""
echo "Current active combo: combo/execution"
echo "Run 'omniroute serve &' to start serving."
