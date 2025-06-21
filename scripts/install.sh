#!/bin/bash
# ABOUTME: Installation script for claude-docker
# ABOUTME: Creates claude-docker directory at home, copies .env.example to .env, adds alias to .zshrc, makes scripts executable.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Create claude persistence directory
mkdir -p "$HOME/.claude-docker/claude-home"

# Copy example env file if doesn't exist
if [ ! -f "$HOME/.claude-docker/.env" ]; then
    cp "$PROJECT_ROOT/.env.example" "$HOME/.claude-docker/.env"
    echo "⚠️  Created .env file at $HOME/.claude-docker/.env"
    echo "   Please edit it with your API keys!"
fi

# Add alias to .zshrc
ALIAS_LINE="alias claude-docker='$PROJECT_ROOT/scripts/claude-docker.sh'"

if ! grep -q "alias claude-docker=" "$HOME/.zshrc"; then
    echo "" >> "$HOME/.zshrc"
    echo "# Claude Docker alias" >> "$HOME/.zshrc"
    echo "$ALIAS_LINE" >> "$HOME/.zshrc"
    echo "✓ Added 'claude-docker' alias to .zshrc"
else
    echo "✓ Claude-docker alias already exists in .zshrc"
fi

# Make scripts executable
chmod +x "$PROJECT_ROOT/scripts/claude-docker.sh"
chmod +x "$PROJECT_ROOT/scripts/startup.sh"

echo ""
echo "Installation complete! 🎉"
echo ""
echo "Next steps:"
echo "1. (Optional) Edit $HOME/.claude-docker/.env with your API keys"
echo "2. Run 'source ~/.zshrc' or start a new terminal"
echo "3. Navigate to any project and run 'claude-docker' to start"
echo "4. If no API key, Claude will prompt for interactive authentication"