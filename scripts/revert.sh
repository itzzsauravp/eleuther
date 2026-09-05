#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Eleuther — 1-Click Rollback / Revert Script
# ═══════════════════════════════════════════════════════════════
# Restores previous configuration from ~/.omniroute-backups/latest
# and removes Eleuther / OmniRoute shell environment blocks.
#
# Usage:
#   ./scripts/revert.sh          # Interactive confirmation
#   ./scripts/revert.sh --yes    # Non-interactive confirmation
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

AUTO_YES=false
for arg in "$@"; do
    case "$arg" in
        -y|--yes) AUTO_YES=true ;;
    esac
done

BACKUP_ROOT="$HOME/.omniroute-backups"
TARGET_BACKUP=""

# Resolve latest backup
if [ -d "$BACKUP_ROOT/latest" ]; then
    TARGET_BACKUP="$BACKUP_ROOT/latest"
elif [ -f "$BACKUP_ROOT/latest.txt" ]; then
    TARGET_BACKUP=$(cat "$BACKUP_ROOT/latest.txt" | tr -d '\r\n')
fi

if [ -z "$TARGET_BACKUP" ] || [ ! -d "$TARGET_BACKUP" ]; then
    LATEST_DIR=$(find "$BACKUP_ROOT" -maxdepth 1 -name "backup-*" -type d 2>/dev/null | sort -r | head -n 1)
    if [ -n "$LATEST_DIR" ] && [ -d "$LATEST_DIR" ]; then
        TARGET_BACKUP="$LATEST_DIR"
    fi
fi

if [ -z "$TARGET_BACKUP" ] || [ ! -d "$TARGET_BACKUP" ]; then
    print_error "No previous backup found at $BACKUP_ROOT."
    echo "If you have a ~/.omniroute.bak directory, you can manually restore it via: cp -r ~/.omniroute.bak ~/.omniroute"
    exit 1
fi

print_header "Eleuther 1-Click Rollback Engine"
print_info "Latest backup located at: $TARGET_BACKUP"

if [ "$AUTO_YES" = false ]; then
    echo -ne "${YELLOW}Are you sure you want to revert all changes and restore this backup? [y/N]: ${NC}"
    read -r CONFIRM
    case "$CONFIRM" in
        [yY][eE][sS]|[yY]) ;;
        *)
            print_warning "Revert cancelled by user."
            exit 0
            ;;
    esac
fi

# Function to remove managed block from shell files cross-platform
clean_shell_rc() {
    local file="$1"
    [ ! -f "$file" ] && return 0

    local tmp_file="${file}.tmp.$$"
    awk '
        BEGIN { skip=0 }
        /# <<< (OmniRoute|Eleuther) Managed Block <<</ { skip=1; next }
        /# >>> (OmniRoute|Eleuther) Managed Block >>>/ { skip=0; next }
        /# ── OmniRoute \+ Claude Code ──/ { skip=1; next }
        skip && /Estimated monthly budget/ { skip=0; next }
        !skip { print }
    ' "$file" > "$tmp_file"

    mv "$tmp_file" "$file"
    print_success "Cleaned Eleuther/OmniRoute exports from $file"
}

MANIFEST="$TARGET_BACKUP/manifest.json"

if [ -f "$MANIFEST" ]; then
    print_info "Reading manifest: $MANIFEST"
    if [ -d "$TARGET_BACKUP/omniroute_home" ]; then
        rm -rf "$HOME/.omniroute"
        cp -r "$TARGET_BACKUP/omniroute_home" "$HOME/.omniroute"
        print_success "Restored ~/.omniroute"
    fi

    if [ -d "$TARGET_BACKUP/claude_home" ]; then
        rm -rf "$HOME/.claude"
        cp -r "$TARGET_BACKUP/claude_home" "$HOME/.claude"
        print_success "Restored ~/.claude"
    fi

    if [ -d "$TARGET_BACKUP/opencode_home" ]; then
        rm -rf "$HOME/.config/opencode"
        cp -r "$TARGET_BACKUP/opencode_home" "$HOME/.config/opencode"
        print_success "Restored ~/.config/opencode"
    fi

    WORKSPACE_DIR="$(pwd)"
    if [ -d "$TARGET_BACKUP/claude_workspace" ]; then
        rm -rf "$WORKSPACE_DIR/.claude"
        cp -r "$TARGET_BACKUP/claude_workspace" "$WORKSPACE_DIR/.claude"
        print_success "Restored workspace .claude"
    elif [ -f "$WORKSPACE_DIR/.claude/commands/optimize.md" ] || [ -f "$WORKSPACE_DIR/.claude/commands/role-skills.md" ]; then
        rm -f "$WORKSPACE_DIR/.claude/commands/optimize.md"
        rm -f "$WORKSPACE_DIR/.claude/commands/role-skills.md"
        rmdir "$WORKSPACE_DIR/.claude/commands" 2>/dev/null || true
        rmdir "$WORKSPACE_DIR/.claude" 2>/dev/null || true
        print_info "Removed injected workspace .claude/commands/"
    fi

    if [ -d "$TARGET_BACKUP/opencode_workspace" ]; then
        rm -rf "$WORKSPACE_DIR/.opencode"
        cp -r "$TARGET_BACKUP/opencode_workspace" "$WORKSPACE_DIR/.opencode"
        print_success "Restored workspace .opencode"
    elif [ -f "$WORKSPACE_DIR/.opencode/rules/omniroute-rules.md" ]; then
        rm -f "$WORKSPACE_DIR/.opencode/rules/omniroute-rules.md"
        rmdir "$WORKSPACE_DIR/.opencode/rules" 2>/dev/null || true
        rmdir "$WORKSPACE_DIR/.opencode" 2>/dev/null || true
        print_info "Removed injected workspace .opencode/rules/"
    fi

    if [ -f "$TARGET_BACKUP/AGENTS.md" ]; then
        cp "$TARGET_BACKUP/AGENTS.md" "$WORKSPACE_DIR/AGENTS.md"
        print_success "Restored workspace AGENTS.md"
    elif [ -f "$WORKSPACE_DIR/AGENTS.md" ]; then
        rm -f "$WORKSPACE_DIR/AGENTS.md"
        print_info "Removed injected workspace AGENTS.md"
    fi

    if [ -f "$TARGET_BACKUP/CONVENTIONS.md" ]; then
        cp "$TARGET_BACKUP/CONVENTIONS.md" "$WORKSPACE_DIR/CONVENTIONS.md"
        print_success "Restored workspace CONVENTIONS.md"
    elif [ -f "$WORKSPACE_DIR/CONVENTIONS.md" ]; then
        rm -f "$WORKSPACE_DIR/CONVENTIONS.md"
        print_info "Removed injected workspace CONVENTIONS.md"
    fi

    if [ -f "$TARGET_BACKUP/.aider.conf.yml" ]; then
        cp "$TARGET_BACKUP/.aider.conf.yml" "$WORKSPACE_DIR/.aider.conf.yml"
        print_success "Restored workspace .aider.conf.yml"
    elif [ -f "$WORKSPACE_DIR/.aider.conf.yml" ]; then
        rm -f "$WORKSPACE_DIR/.aider.conf.yml"
        print_info "Removed injected workspace .aider.conf.yml"
    fi
fi

# 2. Strip shell managed blocks from rc files
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
    clean_shell_rc "$rc"
done

print_header "🎉 Rollback Completed Successfully!"
echo "All configurations have been restored to the state before installation."
echo "Please reload your shell: source ~/.zshrc (or source ~/.bashrc)"
