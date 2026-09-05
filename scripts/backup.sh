#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Eleuther — Zero-Risk Automated Backup Engine
# ═══════════════════════════════════════════════════════════════
# Backs up existing configuration and terminal agent states:
#   - ~/.omniroute
#   - ~/.claude and workspace .claude
#   - ~/.config/opencode and workspace .opencode
#   - workspace AGENTS.md, CONVENTIONS.md, .aider.conf.yml
#   - Eleuther managed shell environment blocks
#
# Generates timestamped snapshot, manifest.json, and updates latest pointer.
# ═══════════════════════════════════════════════════════════════

set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info()    { echo -e "${CYAN}→ $1${NC}"; }

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_ROOT="$HOME/.omniroute-backups"
BACKUP_DIR="$BACKUP_ROOT/backup-$TIMESTAMP"
WORKSPACE_DIR="$(pwd)"

mkdir -p "$BACKUP_DIR"

MANIFEST_FILE="$BACKUP_DIR/manifest.json"

echo "{" > "$MANIFEST_FILE"
echo "  \"timestamp\": \"$TIMESTAMP\"," >> "$MANIFEST_FILE"
echo "  \"workspace\": \"$WORKSPACE_DIR\"," >> "$MANIFEST_FILE"
echo "  \"items\": [" >> "$MANIFEST_FILE"

ITEMS_RECORDED=0

record_backup() {
    local source_path="$1"
    local dest_rel="$2"
    local item_type="$3"

    if [ "$ITEMS_RECORDED" -gt 0 ]; then
        echo "    ," >> "$MANIFEST_FILE"
    fi

    echo "    {" >> "$MANIFEST_FILE"
    echo "      \"source\": \"$source_path\"," >> "$MANIFEST_FILE"
    echo "      \"backup\": \"$dest_rel\"," >> "$MANIFEST_FILE"
    echo "      \"type\": \"$item_type\"" >> "$MANIFEST_FILE"
    echo -n "    }" >> "$MANIFEST_FILE"

    ITEMS_RECORDED=$((ITEMS_RECORDED + 1))
}

# 1. Backup ~/.omniroute
if [ -d "$HOME/.omniroute" ]; then
    cp -r "$HOME/.omniroute" "$BACKUP_DIR/omniroute_home"
    cp -r "$HOME/.omniroute" "$HOME/.omniroute.bak"
    record_backup "$HOME/.omniroute" "omniroute_home" "directory"
    print_success "Backed up ~/.omniroute"
fi

# 2. Backup ~/.claude
if [ -d "$HOME/.claude" ]; then
    cp -r "$HOME/.claude" "$BACKUP_DIR/claude_home"
    cp -r "$HOME/.claude" "$HOME/.claude.bak"
    record_backup "$HOME/.claude" "claude_home" "directory"
    print_success "Backed up ~/.claude"
fi

# 3. Backup workspace .claude
if [ -d "$WORKSPACE_DIR/.claude" ]; then
    cp -r "$WORKSPACE_DIR/.claude" "$BACKUP_DIR/claude_workspace"
    record_backup "$WORKSPACE_DIR/.claude" "claude_workspace" "directory"
    print_success "Backed up workspace .claude"
fi

# 4. Backup ~/.config/opencode
if [ -d "$HOME/.config/opencode" ]; then
    mkdir -p "$BACKUP_DIR/opencode_home"
    cp -r "$HOME/.config/opencode" "$BACKUP_DIR/opencode_home"
    record_backup "$HOME/.config/opencode" "opencode_home" "directory"
    print_success "Backed up ~/.config/opencode"
fi

# 5. Backup workspace .opencode
if [ -d "$WORKSPACE_DIR/.opencode" ]; then
    cp -r "$WORKSPACE_DIR/.opencode" "$BACKUP_DIR/opencode_workspace"
    record_backup "$WORKSPACE_DIR/.opencode" "opencode_workspace" "directory"
    print_success "Backed up workspace .opencode"
fi

# 6. Backup workspace AGENTS.md if present
if [ -f "$WORKSPACE_DIR/AGENTS.md" ]; then
    cp "$WORKSPACE_DIR/AGENTS.md" "$BACKUP_DIR/AGENTS.md"
    record_backup "$WORKSPACE_DIR/AGENTS.md" "AGENTS.md" "file"
    print_success "Backed up workspace AGENTS.md"
fi

# 7. Backup workspace CONVENTIONS.md if present
if [ -f "$WORKSPACE_DIR/CONVENTIONS.md" ]; then
    cp "$WORKSPACE_DIR/CONVENTIONS.md" "$BACKUP_DIR/CONVENTIONS.md"
    record_backup "$WORKSPACE_DIR/CONVENTIONS.md" "CONVENTIONS.md" "file"
    print_success "Backed up workspace CONVENTIONS.md"
fi

# 8. Backup workspace .aider.conf.yml if present
if [ -f "$WORKSPACE_DIR/.aider.conf.yml" ]; then
    cp "$WORKSPACE_DIR/.aider.conf.yml" "$BACKUP_DIR/.aider.conf.yml"
    record_backup "$WORKSPACE_DIR/.aider.conf.yml" ".aider.conf.yml" "file"
    print_success "Backed up workspace .aider.conf.yml"
fi

# 9. Backup shell RC files if they contain Eleuther/OmniRoute managed blocks
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    if [ -f "$rc" ] && grep -q "OmniRoute Managed Block\|Eleuther Managed Block" "$rc" 2>/dev/null; then
        rc_name=$(basename "$rc")
        cp "$rc" "$BACKUP_DIR/$rc_name"
        record_backup "$rc" "$rc_name" "shell_rc"
        print_success "Backed up shell profile: $rc"
    fi
done

echo "" >> "$MANIFEST_FILE"
echo "  ]" >> "$MANIFEST_FILE"
echo "}" >> "$MANIFEST_FILE"

# Update latest pointer (cross-platform fallback)
LATEST_LINK="$BACKUP_ROOT/latest"
rm -f "$LATEST_LINK" 2>/dev/null || true
if ln -s "$BACKUP_DIR" "$LATEST_LINK" 2>/dev/null; then
    :
else
    echo "$BACKUP_DIR" > "$BACKUP_ROOT/latest.txt"
fi

print_success "Safety backup complete: $BACKUP_DIR"
