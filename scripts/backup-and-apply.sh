#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# OmniRoute — Re-apply Settings & Combos
# ═══════════════════════════════════════════════════════════════
# Safely creates a backup and re-applies current keys and combos.
# Note: For full onboarding, use ./scripts/install.sh
# ═══════════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run safe backup engine
bash "$SCRIPT_DIR/backup.sh"

# Re-register API keys if present
if [ -f "$HOME/.omniroute/api-keys.env" ]; then
    bash "$SCRIPT_DIR/add-keys.sh"
fi

# Rebuild routing combos
bash "$SCRIPT_DIR/build-combos.sh" --switch

echo ""
echo "✓ Settings and combos re-applied successfully!"
echo "To modify role or agent skills, run: ./scripts/install.sh"
