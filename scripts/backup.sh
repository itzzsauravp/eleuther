#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Eleuther — Robust Safety Backup Engine
# ═══════════════════════════════════════════════════════════════
# Safely snapshots and protects user configurations, secrets, and agent states:
#   - OmniRoute database, encryption keys, and credentials (~/.omniroute)
#   - Claude Code settings and login sessions (~/.claude and workspace .claude)
#   - Codex, OpenCode, and Aider configurations and rules
#   - Full shell profiles (~/.zshrc, ~/.bashrc, ~/.bash_profile, ~/.profile)
#
# Storage:
#   All backups are saved to: ~/.eleuther-backups/backup-<TIMESTAMP>/
#
# Flags:
#   -y, --yes, --all    Backup all detected items non-interactively
# ═══════════════════════════════════════════════════════════════

set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_error()   { echo -e "${RED}✖ $1${NC}"; }
print_info()    { echo -e "${CYAN}→ $1${NC}"; }
print_header() {
    echo ""; echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} $1${NC}"; echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"; echo ""
}

AUTO_ALL=false
for arg in "$@"; do
    case "$arg" in
        -y|--yes|--all) AUTO_ALL=true ;;
    esac
done

WORKSPACE_DIR="$(pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_ROOT="$HOME/.eleuther-backups"
BACKUP_DIR="$BACKUP_ROOT/backup-$TIMESTAMP"



ask_confirm() {
    local prompt="$1"
    local default_yes="${2:-true}"
    if [ "$AUTO_ALL" = true ]; then
        return 0
    fi
    if [ "$default_yes" = true ]; then
        echo -ne "${BOLD}${prompt} [Y/n]: ${NC}"
        read -r res
        case "$res" in
            [nN][oO]|[nN]) return 1 ;;
            *) return 0 ;;
        esac
    else
        echo -ne "${BOLD}${prompt} [y/N]: ${NC}"
        read -r res
        case "$res" in
            [yY][eE][sS]|[yY]) return 0 ;;
            *) return 1 ;;
        esac
    fi
}

print_header "Eleuther Configuration & Agent Backup Engine"

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

# 1. OmniRoute Home (~/.omniroute)
if [ -d "$HOME/.omniroute" ]; then
    if ask_confirm "Back up OmniRoute settings, database, and secrets (~/.omniroute)?" true; then
        cp -r "$HOME/.omniroute" "$BACKUP_DIR/omniroute_home"
        record_backup "$HOME/.omniroute" "omniroute_home" "directory"
        print_success "Backed up ~/.omniroute"
    fi
fi

# 2. Claude Code Home & Workspace (.claude)
if [ -d "$HOME/.claude" ]; then
    if ask_confirm "Back up global Claude Code configuration & logins (~/.claude)?" true; then
        cp -r "$HOME/.claude" "$BACKUP_DIR/claude_home"
        record_backup "$HOME/.claude" "claude_home" "directory"
        print_success "Backed up ~/.claude"
    fi
fi

if [ -d "$WORKSPACE_DIR/.claude" ]; then
    if ask_confirm "Back up workspace Claude Code commands ($WORKSPACE_DIR/.claude)?" true; then
        cp -r "$WORKSPACE_DIR/.claude" "$BACKUP_DIR/claude_workspace"
        record_backup "$WORKSPACE_DIR/.claude" "claude_workspace" "directory"
        print_success "Backed up workspace .claude"
    fi
fi

# 3. OpenCode Settings
if [ -d "$HOME/.config/opencode" ]; then
    if ask_confirm "Back up global OpenCode configuration (~/.config/opencode)?" true; then
        mkdir -p "$BACKUP_DIR/opencode_home"
        cp -r "$HOME/.config/opencode" "$BACKUP_DIR/opencode_home"
        record_backup "$HOME/.config/opencode" "opencode_home" "directory"
        print_success "Backed up ~/.config/opencode"
    fi
fi

if [ -d "$WORKSPACE_DIR/.opencode" ]; then
    if ask_confirm "Back up workspace OpenCode rules ($WORKSPACE_DIR/.opencode)?" true; then
        cp -r "$WORKSPACE_DIR/.opencode" "$BACKUP_DIR/opencode_workspace"
        record_backup "$WORKSPACE_DIR/.opencode" "opencode_workspace" "directory"
        print_success "Backed up workspace .opencode"
    fi
fi

# 4. OpenAI Codex & CLI Settings
if [ -d "$HOME/.codex" ]; then
    if ask_confirm "Back up global Codex configuration (~/.codex)?" true; then
        cp -r "$HOME/.codex" "$BACKUP_DIR/codex_home"
        record_backup "$HOME/.codex" "codex_home" "directory"
        print_success "Backed up ~/.codex"
    fi
fi

if [ -f "$WORKSPACE_DIR/AGENTS.md" ]; then
    if ask_confirm "Back up workspace AGENTS.md?" true; then
        cp "$WORKSPACE_DIR/AGENTS.md" "$BACKUP_DIR/AGENTS.md"
        record_backup "$WORKSPACE_DIR/AGENTS.md" "AGENTS.md" "file"
        print_success "Backed up workspace AGENTS.md"
    fi
fi

# 5. Aider CLI Settings
if [ -f "$WORKSPACE_DIR/CONVENTIONS.md" ]; then
    if ask_confirm "Back up workspace CONVENTIONS.md?" true; then
        cp "$WORKSPACE_DIR/CONVENTIONS.md" "$BACKUP_DIR/CONVENTIONS.md"
        record_backup "$WORKSPACE_DIR/CONVENTIONS.md" "CONVENTIONS.md" "file"
        print_success "Backed up workspace CONVENTIONS.md"
    fi
fi

if [ -f "$WORKSPACE_DIR/.aider.conf.yml" ]; then
    if ask_confirm "Back up workspace .aider.conf.yml?" true; then
        cp "$WORKSPACE_DIR/.aider.conf.yml" "$BACKUP_DIR/.aider.conf.yml"
        record_backup "$WORKSPACE_DIR/.aider.conf.yml" ".aider.conf.yml" "file"
        print_success "Backed up workspace .aider.conf.yml"
    fi
fi

# 6. Full Shell Configuration Files
if ask_confirm "Back up shell configuration files (.zshrc, .bashrc, .bash_profile, .profile)?" true; then
    for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
        if [ -f "$rc" ]; then
            rc_name=$(basename "$rc")
            cp "$rc" "$BACKUP_DIR/$rc_name"
            record_backup "$rc" "$rc_name" "shell_rc"
            print_success "Backed up $rc"
        fi
    done
fi

echo "" >> "$MANIFEST_FILE"
echo "  ]" >> "$MANIFEST_FILE"
echo "}" >> "$MANIFEST_FILE"

# Update latest pointer (symlink + fallback txt)
LATEST_LINK="$BACKUP_ROOT/latest"
rm -f "$LATEST_LINK" 2>/dev/null || true
if ln -s "$BACKUP_DIR" "$LATEST_LINK" 2>/dev/null; then
    :
else
    echo "$BACKUP_DIR" > "$BACKUP_ROOT/latest.txt"
fi

echo ""
print_success "Backup completed successfully!"
print_info "Saved to:    ${CYAN}$BACKUP_DIR${NC}"
print_info "Latest link: ${CYAN}$LATEST_LINK${NC}"
