#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# OmniRoute — Setup Redirection Script
# ═══════════════════════════════════════════════════════════════
# Note: This script delegates to ./scripts/install.sh for unified
# multi-agent onboarding, backups, and role skill configuration.
# ═══════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "→ Running unified installer: ./scripts/install.sh ..."
exec bash "$SCRIPT_DIR/install.sh" "$@"
