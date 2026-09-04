#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# Test OmniRoute Combos
# ═══════════════════════════════════════════════════════════════
# This script tests all configured combos

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error() { echo -e "${RED}✖ $1${NC}"; }

print_header "Testing OmniRoute Combos"

# Test prompt
TEST_PROMPT="${1:-Write a simple Python function to calculate factorial}"

echo "📝 Test prompt: $TEST_PROMPT"
echo ""

# Get list of combos
COMBOS=$(omniroute combo list 2>&1 | grep -E "○|●" | awk '{print $2}' | tr -d ' ')

if [ -z "$COMBOS" ]; then
    print_error "No combos found!"
    echo "Run ./scripts/create-combos.sh first"
    exit 1
fi

echo "🔍 Found combos: $COMBOS"
echo ""

# Test each combo
for combo in $COMBOS; do
    print_header "Testing: $combo"

    echo "Simulating routing..."
    omniroute simulate "$TEST_PROMPT" --combo "$combo" --explain 2>&1

    echo ""
    echo "Press Enter to continue to next combo..."
    read -r
done

print_header "Testing Complete"

echo "Summary:"
echo ""
for combo in $COMBOS; do
    echo "  - $combo"
done

echo ""
echo "To activate a combo:"
echo "  omniroute combo switch <combo-name>"
echo ""
echo "To run a full test with actual API call:"
echo "  omniroute chat '$TEST_PROMPT' --combo mega-free"
