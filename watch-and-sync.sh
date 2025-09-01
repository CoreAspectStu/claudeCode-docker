#!/bin/bash

# Watch local Claude files and auto-sync changes
# Requires: fswatch (Mac) or inotify-tools (Linux)

set -e

# Load configuration
if [ -f .env.sync.local ]; then
    source .env.sync.local
elif [ -f .env.sync ]; then
    source .env.sync
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}👁️  Claude Auth File Watcher${NC}"
echo "================================"
echo "Watching for changes in:"
echo "  - ~/.claude.json"
echo "  - ~/.claude/"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Detect OS and use appropriate file watcher
if command -v fswatch >/dev/null 2>&1; then
    # macOS with fswatch
    echo -e "${YELLOW}Using fswatch (macOS)${NC}"
    fswatch -o "$HOME/.claude.json" "$HOME/.claude/" | while read f; do
        echo -e "${YELLOW}📝 Change detected, syncing...${NC}"
        ./sync-claude-auth.sh --quiet
        echo -e "${GREEN}✅ Sync complete${NC}"
    done
elif command -v inotifywait >/dev/null 2>&1; then
    # Linux with inotify-tools
    echo -e "${YELLOW}Using inotify-tools (Linux)${NC}"
    while true; do
        inotifywait -r -e modify,create,delete "$HOME/.claude.json" "$HOME/.claude/" 2>/dev/null
        echo -e "${YELLOW}📝 Change detected, syncing...${NC}"
        sleep 2  # Debounce
        ./sync-claude-auth.sh --quiet
        echo -e "${GREEN}✅ Sync complete${NC}"
    done
else
    echo -e "${RED}❌ Error: No file watcher found${NC}"
    echo ""
    echo "Please install a file watcher:"
    echo "  macOS:  brew install fswatch"
    echo "  Linux:  sudo apt-get install inotify-tools"
    echo ""
    echo "Alternative: Run sync manually with:"
    echo "  ./sync-claude-auth.sh"
    exit 1
fi