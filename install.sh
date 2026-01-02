#!/bin/bash
# Ralph Loop Linux - Project-Level Installer
# Run this script from your project root directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Parse arguments
FORCE=false
KEEP_SOURCE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force)
            FORCE=true
            ;;
        -k|--keep-source)
            KEEP_SOURCE=true
            ;;
        -h|--help)
            echo "Usage: install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -f, --force        Reinstall even if already installed"
            echo "  -k, --keep-source  Keep the source repository after installation"
            echo "  -h, --help         Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Ralph Loop Linux Installer${NC}"
echo -e "${CYAN}  Project-Level Installation${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check for jq dependency
if ! command -v jq &> /dev/null; then
    echo -e "${RED}[!] Error: jq is required but not installed.${NC}"
    echo -e "${YELLOW}    Install it with:${NC}"
    echo -e "${GRAY}      Ubuntu/Debian: sudo apt install jq${NC}"
    echo -e "${GRAY}      Fedora/RHEL:   sudo dnf install jq${NC}"
    echo -e "${GRAY}      macOS:         brew install jq${NC}"
    echo ""
    exit 1
fi

claude_dir=".claude"
repo_dir="$claude_dir/ralph-loop-linux"

# Check if already installed
if [[ -f "$claude_dir/commands/ralph-loop.md" ]] && [[ "$FORCE" == "false" ]]; then
    echo -e "${YELLOW}[!] Ralph Loop appears to be already installed.${NC}"
    echo -e "${YELLOW}    Use --force to reinstall.${NC}"
    echo ""
    exit 0
fi

# Step 1: Clone repository if not exists
echo -e "${GREEN}[1/5] Cloning repository...${NC}"
if [[ -d "$repo_dir" ]]; then
    echo -e "${GRAY}      Repository already exists, pulling latest...${NC}"
    (cd "$repo_dir" && git pull --quiet)
else
    git clone --quiet https://github.com/mannnrachman/ralph-loop-linux "$repo_dir"
fi
echo -e "${GRAY}      Done!${NC}"

# Step 2: Create directories
echo -e "${GREEN}[2/5] Creating directories...${NC}"
for dir in "$claude_dir/commands" "$claude_dir/hooks" "$claude_dir/scripts"; do
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        echo -e "${GRAY}      Created: $dir${NC}"
    fi
done
echo -e "${GRAY}      Done!${NC}"

# Step 3: Copy files
echo -e "${GREEN}[3/5] Copying files...${NC}"

# Commands
cp "$repo_dir/commands/ralph-loop.md" "$claude_dir/commands/ralph-loop.md"
cp "$repo_dir/commands/cancel-ralph.md" "$claude_dir/commands/cancel-ralph.md"
cp "$repo_dir/commands/help-ralph.md" "$claude_dir/commands/help-ralph.md"
echo -e "${GRAY}      Copied commands${NC}"

# Hooks
cp "$repo_dir/hooks/stop-hook.sh" "$claude_dir/hooks/stop-hook.sh"
chmod +x "$claude_dir/hooks/stop-hook.sh"
echo -e "${GRAY}      Copied hooks${NC}"

# Scripts
cp "$repo_dir/scripts/setup-ralph-loop.sh" "$claude_dir/scripts/setup-ralph-loop.sh"
chmod +x "$claude_dir/scripts/setup-ralph-loop.sh"
echo -e "${GRAY}      Copied scripts${NC}"

# Settings
cp "$repo_dir/settings.local.json" "$claude_dir/settings.local.json"
echo -e "${GRAY}      Copied settings.local.json${NC}"

echo -e "${GRAY}      Done!${NC}"

# Step 4: Verify installation
echo -e "${GREEN}[4/5] Verifying installation...${NC}"
required_files=(
    "$claude_dir/commands/ralph-loop.md"
    "$claude_dir/commands/cancel-ralph.md"
    "$claude_dir/commands/help-ralph.md"
    "$claude_dir/hooks/stop-hook.sh"
    "$claude_dir/scripts/setup-ralph-loop.sh"
    "$claude_dir/settings.local.json"
)

all_present=true
for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}      Missing: $file${NC}"
        all_present=false
    fi
done

if [[ "$all_present" == "true" ]]; then
    echo -e "${GRAY}      All files verified!${NC}"
fi

# Step 5: Cleanup source repository
echo -e "${GREEN}[5/5] Cleaning up...${NC}"
if [[ "$KEEP_SOURCE" == "false" ]]; then
    if [[ -d "$repo_dir" ]]; then
        rm -rf "$repo_dir"
        echo -e "${GRAY}      Removed source repository${NC}"
    fi
    echo -e "${GRAY}      Done!${NC}"
else
    echo -e "${GRAY}      Skipped (keeping source)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${WHITE}Available commands:${NC}"
echo -e "${GRAY}  /ralph-loop    - Start a Ralph loop${NC}"
echo -e "${GRAY}  /cancel-ralph  - Cancel active loop${NC}"
echo -e "${GRAY}  /help-ralph    - Show help${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "${GRAY}  1. Restart Claude Code VSCode extension or CLI${NC}"
echo -e "${GRAY}  2. Try: /ralph-loop \"Your task here\" --max-iterations 10${NC}"
echo ""
