#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Eleuther — Granular Uninstaller & Cleanup Engine
# ═══════════════════════════════════════════════════════════════
# Interactively cleans Eleuther and OmniRoute components:
#   - Granularly removes shell environment blocks (per agent or telemetry)
#   - Safely preserves user-defined environment variables
#   - Removes ~/.omniroute (secrets, keys, database)
#   - Cleans agent configurations (Claude, Codex, OpenCode, Aider)
#   - Optionally deletes backup archives (~/.eleuther-backups)
#   - Optionally uninstalls global npm packages
#   - Optionally restores original files from a safety backup
#
# Flags:
#   -y, --yes, --all    Remove all components non-interactively
# ═══════════════════════════════════════════════════════════════

set +e

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
BACKUP_ROOT="$HOME/.eleuther-backups"

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

# Function to remove a specific tagged block from a file
remove_tagged_block() {
    local file="$1"
    local tag_regex="$2"
    [ ! -f "$file" ] && return 0

    local tmp_file="${file}.tmp.$$"
    awk -v pattern="$tag_regex" '
        BEGIN { skip=0 }
        $0 ~ "# <<< Eleuther: " pattern " <<<" { skip=1; next }
        $0 ~ "# >>> Eleuther: " pattern " >>>" { skip=0; next }
        !skip { print }
    ' "$file" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$file"
}



print_header "Eleuther Granular Uninstaller & Cleanup Engine"
echo "This wizard allows you to selectively clean components or remove everything."
echo ""

# ── 0. Kill OmniRoute Server ─────────────────────────────────────────────────
print_header "Killing OmniRoute Server Process"

# Read the port from .env, fall back to 20128
OMNI_PORT=20128
if [ -f "$HOME/.omniroute/.env" ]; then
    _port=$(grep -E '^PORT=' "$HOME/.omniroute/.env" | cut -d= -f2 | tr -d '[:space:]')
    [ -n "$_port" ] && OMNI_PORT="$_port"
fi
print_info "Targeting OmniRoute on port $OMNI_PORT..."

kill_omniroute() {
    local killed=0

    # Method 1: lsof — most reliable on macOS & Linux
    if command -v lsof >/dev/null 2>&1; then
        PIDS=$(lsof -ti tcp:"$OMNI_PORT" 2>/dev/null || true)
        for pid in $PIDS; do
            kill -9 "$pid" 2>/dev/null && print_success "Killed PID $pid (lsof)" && killed=1
        done
    fi

    # Method 2: fuser — Linux standard
    if command -v fuser >/dev/null 2>&1; then
        fuser -k -KILL "${OMNI_PORT}/tcp" >/dev/null 2>&1 && print_success "Killed via fuser" && killed=1 || true
    fi

    # Method 3: ss + kill — fallback for minimal Linux environments
    if command -v ss >/dev/null 2>&1; then
        PIDS=$(ss -tlnp "sport = :$OMNI_PORT" 2>/dev/null | grep -oP 'pid=\K[0-9]+' || true)
        for pid in $PIDS; do
            kill -9 "$pid" 2>/dev/null && print_success "Killed PID $pid (ss)" && killed=1
        done
    fi

    # Method 4: pkill on process name — catches any stray omniroute node processes
    pkill -9 -f "omniroute" 2>/dev/null && print_success "Killed omniroute process(es) by name (pkill)" && killed=1 || true

    # Final verification
    sleep 0.5
    if command -v lsof >/dev/null 2>&1 && lsof -ti tcp:"$OMNI_PORT" >/dev/null 2>&1; then
        print_error "Port $OMNI_PORT still in use after kill attempts — you may need to reboot or kill manually."
    elif command -v ss >/dev/null 2>&1 && ss -tlnp 2>/dev/null | grep -q ":$OMNI_PORT "; then
        print_error "Port $OMNI_PORT still in use after kill attempts — you may need to reboot or kill manually."
    else
        if [ "$killed" -eq 1 ]; then
            print_success "Port $OMNI_PORT is clear — OmniRoute is 100% stopped."
        else
            print_info "OmniRoute was not running on port $OMNI_PORT."
        fi
    fi
}

kill_omniroute

# 1. Option to restore from backup first
if [ -d "$BACKUP_ROOT" ]; then
    LATEST_BACKUP=""
    if [ -d "$BACKUP_ROOT/latest" ]; then
        LATEST_BACKUP="$BACKUP_ROOT/latest"
    elif [ -f "$BACKUP_ROOT/latest.txt" ]; then
        LATEST_BACKUP=$(cat "$BACKUP_ROOT/latest.txt" | tr -d '\r\n')
    fi

    if [ -n "$LATEST_BACKUP" ] && [ -d "$LATEST_BACKUP" ]; then
        if ask_confirm "Restore your original configurations from backup ($LATEST_BACKUP) before uninstalling?" false; then
            print_info "Restoring from $LATEST_BACKUP..."
            [ -d "$LATEST_BACKUP/omniroute_home" ] && rm -rf "$HOME/.omniroute" && cp -r "$LATEST_BACKUP/omniroute_home" "$HOME/.omniroute" && print_success "Restored ~/.omniroute"
            [ -d "$LATEST_BACKUP/claude_home" ] && rm -rf "$HOME/.claude" && cp -r "$LATEST_BACKUP/claude_home" "$HOME/.claude" && print_success "Restored ~/.claude"
            [ -d "$LATEST_BACKUP/claude_workspace" ] && cp -r "$LATEST_BACKUP/claude_workspace" "$WORKSPACE_DIR/.claude" && print_success "Restored workspace .claude"
            [ -f "$LATEST_BACKUP/AGENTS.md" ] && cp "$LATEST_BACKUP/AGENTS.md" "$WORKSPACE_DIR/AGENTS.md" && print_success "Restored AGENTS.md"
            [ -f "$LATEST_BACKUP/CONVENTIONS.md" ] && cp "$LATEST_BACKUP/CONVENTIONS.md" "$WORKSPACE_DIR/CONVENTIONS.md" && print_success "Restored CONVENTIONS.md"
            [ -f "$LATEST_BACKUP/.aider.conf.yml" ] && cp "$LATEST_BACKUP/.aider.conf.yml" "$WORKSPACE_DIR/.aider.conf.yml" && print_success "Restored .aider.conf.yml"
        fi
    fi
fi

# 2. Granular Shell Profile Cleaning
print_header "Shell Environment Variables & Aliases"

SHELL_FILES=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile")
DETECTED_TELEMETRY=false
DETECTED_CLAUDE=false
DETECTED_CODEX=false
DETECTED_OPENCODE=false
DETECTED_AIDER=false

for rc in "${SHELL_FILES[@]}"; do
    if [ -f "$rc" ]; then
        grep -q "# <<< Eleuther: Telemetry <<<" "$rc" 2>/dev/null && DETECTED_TELEMETRY=true
        grep -q "# <<< Eleuther: Agent claude <<<" "$rc" 2>/dev/null && DETECTED_CLAUDE=true
        grep -q "# <<< Eleuther: Agent codex <<<" "$rc" 2>/dev/null && DETECTED_CODEX=true
        grep -q "# <<< Eleuther: Agent opencode <<<" "$rc" 2>/dev/null && DETECTED_OPENCODE=true
        grep -q "# <<< Eleuther: Agent aider <<<" "$rc" 2>/dev/null && DETECTED_AIDER=true
    fi
done

echo "Detected Eleuther items in your shell profiles:"
[ "$DETECTED_TELEMETRY" = true ] && echo -e "  - ${CYAN}OmniRoute Monitoring & Telemetry Aliases${NC}"
[ "$DETECTED_CLAUDE" = true ]    && echo -e "  - ${CYAN}Claude Code Proxy Variables${NC}"
[ "$DETECTED_CODEX" = true ]     && echo -e "  - ${CYAN}OpenAI Codex / CLI Proxy Variables${NC}"
[ "$DETECTED_OPENCODE" = true ]  && echo -e "  - ${CYAN}OpenCode Proxy Variables${NC}"
[ "$DETECTED_AIDER" = true ]     && echo -e "  - ${CYAN}Aider CLI Proxy Variables${NC}"

if [ "$DETECTED_TELEMETRY" = false ] && [ "$DETECTED_CLAUDE" = false ] && \
   [ "$DETECTED_CODEX" = false ] && [ "$DETECTED_OPENCODE" = false ] && \
   [ "$DETECTED_AIDER" = false ]; then
    print_info "No Eleuther environment variables found in shell profiles."
else
    echo ""
    if ask_confirm "Remove ALL Eleuther shell variables and aliases?" false; then
        for rc in "${SHELL_FILES[@]}"; do
            remove_tagged_block "$rc" ".*"
        done
        print_success "Removed all Eleuther blocks from shell profiles"
    else
        # Selective removal
        if [ "$DETECTED_TELEMETRY" = true ]; then
            if ask_confirm "Remove OmniRoute Telemetry & Monitoring aliases?" true; then
                for rc in "${SHELL_FILES[@]}"; do remove_tagged_block "$rc" "Telemetry"; done
                print_success "Removed Telemetry aliases"
            fi
        fi
        if [ "$DETECTED_CLAUDE" = true ]; then
            if ask_confirm "Remove Claude Code environment variables?" true; then
                for rc in "${SHELL_FILES[@]}"; do remove_tagged_block "$rc" "Agent claude"; done
                print_success "Removed Claude Code variables"
            fi
        fi
        if [ "$DETECTED_CODEX" = true ]; then
            if ask_confirm "Remove Codex environment variables?" true; then
                for rc in "${SHELL_FILES[@]}"; do remove_tagged_block "$rc" "Agent codex"; done
                print_success "Removed Codex variables"
            fi
        fi
        if [ "$DETECTED_OPENCODE" = true ]; then
            if ask_confirm "Remove OpenCode environment variables?" true; then
                for rc in "${SHELL_FILES[@]}"; do remove_tagged_block "$rc" "Agent opencode"; done
                print_success "Removed OpenCode variables"
            fi
        fi
        if [ "$DETECTED_AIDER" = true ]; then
            if ask_confirm "Remove Aider environment variables?" true; then
                for rc in "${SHELL_FILES[@]}"; do remove_tagged_block "$rc" "Agent aider"; done
                print_success "Removed Aider variables"
            fi
        fi
    fi
fi

# 3. Remove ~/.omniroute
print_header "OmniRoute Data & Keys"
if [ -d "$HOME/.omniroute" ]; then
    echo -e "${YELLOW}⚠ ~/.omniroute contains your SQLite database, encryption keys, and api-keys.env.${NC}"
    if ask_confirm "Delete ~/.omniroute directory?" false; then
        rm -rf "$HOME/.omniroute"
        print_success "Deleted ~/.omniroute"
    else
        print_info "Kept ~/.omniroute intact"
    fi
fi

# 4. Remove generated agent skills & rules
print_header "Agent Workspace Rules & Skills"
if ask_confirm "Clean generated role skills and agent configs from workspace?" true; then
    rm -rf "$WORKSPACE_DIR/.claude/commands/role-skills.md" "$WORKSPACE_DIR/.claude/commands/optimize.md" 2>/dev/null || true
    rm -rf "$HOME/.claude/commands/role-skills.md" "$HOME/.claude/commands/optimize.md" 2>/dev/null || true
    rm -f "$WORKSPACE_DIR/AGENTS.md" "$WORKSPACE_DIR/CONVENTIONS.md" "$WORKSPACE_DIR/.aider.conf.yml" 2>/dev/null || true
    rm -rf "$WORKSPACE_DIR/.opencode/rules/omniroute-rules.md" 2>/dev/null || true
    print_success "Cleaned agent configs and role skills"
fi

# 5. Remove backups
print_header "Backup Archives"
if [ -d "$BACKUP_ROOT" ]; then
    if ask_confirm "Delete backup archives directory ($BACKUP_ROOT)?" false; then
        rm -rf "$BACKUP_ROOT"
        print_success "Deleted $BACKUP_ROOT"
    else
        print_info "Kept backups safely in $BACKUP_ROOT"
    fi
fi

# 6. Global npm packages
print_header "Global Packages"

# Invalidate shell command cache (universal in bash/zsh)
hash -r 2>/dev/null || true

# Universal check: standard npm global check OR executable in PATH
if npm list -g --depth=0 omniroute >/dev/null 2>&1 || command -v omniroute >/dev/null 2>&1; then
    if ask_confirm "Uninstall OmniRoute global npm package (npm uninstall -g omniroute)?" false; then
        print_info "Uninstalling omniroute..."
        npm uninstall -g omniroute 2>/dev/null || sudo npm uninstall -g omniroute 2>/dev/null || true

        # Clean up any leftover binary in npm prefix bin if npm left an orphan
        NPM_BIN="$(npm prefix -g 2>/dev/null)/bin/omniroute"
        ([ -f "$NPM_BIN" ] || [ -L "$NPM_BIN" ]) && rm -f "$NPM_BIN" 2>/dev/null || true

        # Optional cleanups for environments with shims (mise/asdf), no-op on normal machines
        command -v mise >/dev/null 2>&1 && (mise reshim 2>/dev/null || rm -f "$HOME/.local/share/mise/shims/omniroute" 2>/dev/null || true)
        command -v asdf >/dev/null 2>&1 && asdf reshim 2>/dev/null || true

        # Invalidate shell command lookup cache for this session
        hash -r 2>/dev/null || true

        print_success "OmniRoute uninstalled"
    fi
fi

echo ""
print_header "Cleanup Complete!"
print_info "Remember to reload your shell: ${CYAN}source ~/.bashrc${NC} or ${CYAN}source ~/.zshrc${NC}"
echo ""
