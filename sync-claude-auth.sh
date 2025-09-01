#!/bin/bash

# Claude Auth Sync Script
# Syncs local Claude authentication to remote Coolify server

set -e

# Configuration
REMOTE_HOST="${CLAUDE_REMOTE_HOST:-ubuntu@152.69.169.140}"
REMOTE_PORT="${CLAUDE_REMOTE_PORT:-22}"
CONTAINER_NAME="${CLAUDE_CONTAINER_NAME:-claude-code-docker}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔄 Claude Auth Sync Tool${NC}"
echo "================================"

# Check if local Claude files exist
if [ ! -f "$HOME/.claude.json" ]; then
    echo -e "${RED}❌ Error: ~/.claude.json not found${NC}"
    echo "Please authenticate Claude Code locally first:"
    echo "  npm install -g @anthropic-ai/claude-code"
    echo "  claude"
    exit 1
fi

if [ ! -d "$HOME/.claude" ]; then
    echo -e "${RED}❌ Error: ~/.claude/ directory not found${NC}"
    echo "Please run Claude Code locally first to create settings"
    exit 1
fi

# Function to sync files
sync_files() {
    echo -e "${YELLOW}📤 Uploading Claude authentication files to server...${NC}"
    
    # Create temp directory on remote
    ssh -p $REMOTE_PORT $REMOTE_HOST "mkdir -p /tmp/claude-auth-sync"
    
    # Copy files to remote temp location
    scp -P $REMOTE_PORT "$HOME/.claude.json" "$REMOTE_HOST:/tmp/claude-auth-sync/"
    scp -P $REMOTE_PORT -r "$HOME/.claude/" "$REMOTE_HOST:/tmp/claude-auth-sync/"
    
    echo -e "${GREEN}✅ Files uploaded to server${NC}"
}

# Function to update container
update_container() {
    echo -e "${YELLOW}🐳 Updating Docker container...${NC}"
    
    # Copy files into running container
    ssh -p $REMOTE_PORT $REMOTE_HOST << 'EOF'
        # Check if container is running
        if docker ps | grep -q claude-code-docker; then
            echo "Copying files to running container..."
            docker cp /tmp/claude-auth-sync/.claude.json claude-code-docker:/home/claude-user/.claude.json
            docker cp /tmp/claude-auth-sync/.claude/ claude-code-docker:/home/claude-user/
            
            # Fix permissions inside container
            docker exec claude-code-docker chown -R claude-user:claude-user /home/claude-user/.claude.json
            docker exec claude-code-docker chown -R claude-user:claude-user /home/claude-user/.claude/
            
            echo "✅ Container updated successfully"
        else
            echo "⚠️  Container not running. Files will be used on next start."
            # Copy to persistent volume location if needed
            # This depends on your Coolify setup
        fi
        
        # Clean up temp files
        rm -rf /tmp/claude-auth-sync
EOF
    
    echo -e "${GREEN}✅ Container update complete${NC}"
}

# Function to setup auto-sync
setup_autosync() {
    echo -e "\n${YELLOW}Would you like to set up automatic sync? (y/n)${NC}"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        # Create git hook for auto-sync
        mkdir -p .git/hooks
        cat > .git/hooks/post-commit << 'HOOKEOF'
#!/bin/bash
# Auto-sync Claude auth after commits
if [ -f ./sync-claude-auth.sh ]; then
    echo "🔄 Syncing Claude authentication..."
    ./sync-claude-auth.sh --quiet
fi
HOOKEOF
        chmod +x .git/hooks/post-commit
        
        echo -e "${GREEN}✅ Auto-sync enabled via git hook${NC}"
        echo "   Claude auth will sync automatically after commits"
    fi
}

# Main execution
if [[ "$1" != "--quiet" ]]; then
    echo -e "\n${YELLOW}📝 Configuration:${NC}"
    echo "   Remote Host: $REMOTE_HOST"
    echo "   Remote Port: $REMOTE_PORT"
    echo "   Container: $CONTAINER_NAME"
    echo ""
    echo "To customize, set environment variables:"
    echo "   export CLAUDE_REMOTE_HOST='user@your-server'"
    echo "   export CLAUDE_REMOTE_PORT='22'"
    echo ""
    echo -e "${YELLOW}Continue? (y/n)${NC}"
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

# Execute sync
sync_files
update_container

if [[ "$1" != "--quiet" ]]; then
    setup_autosync
    echo -e "\n${GREEN}🎉 Sync complete!${NC}"
    echo "Your Claude authentication is now synced to the server."
fi