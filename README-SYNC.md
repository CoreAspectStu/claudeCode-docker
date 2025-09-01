# Claude Authentication Sync

Automate syncing your local Claude authentication to your Coolify server.

## Quick Start

1. **Initial Setup**
   ```bash
   # Make scripts executable
   chmod +x sync-claude-auth.sh watch-and-sync.sh
   
   # Configure your server (optional - uses defaults for your server)
   cp .env.sync .env.sync.local
   nano .env.sync.local  # Edit server details if needed
   ```

2. **Manual Sync**
   ```bash
   ./sync-claude-auth.sh
   ```

3. **Auto-Sync on File Changes** (Optional)
   ```bash
   # Install file watcher first:
   # macOS: brew install fswatch
   # Linux: sudo apt-get install inotify-tools
   
   # Run watcher
   ./watch-and-sync.sh
   ```

## Features

### 🔄 Manual Sync
- Run `./sync-claude-auth.sh` anytime to sync your auth
- Automatically copies `.claude.json` and `.claude/` directory
- Updates running Docker container
- Fixes permissions automatically

### 👁️ File Watcher (Auto-Sync)
- Watches for changes in Claude files
- Automatically syncs when you:
  - Re-authenticate Claude
  - Update MCP settings
  - Modify Claude preferences

### 🔗 Git Hook Integration
- Optional: Auto-sync after every git commit
- Ensures your deployed version always has latest auth

## Configuration

Edit `.env.sync.local` to customize:

```bash
# Your Coolify server
CLAUDE_REMOTE_HOST=ubuntu@152.69.169.140
CLAUDE_REMOTE_PORT=22
CLAUDE_CONTAINER_NAME=claude-code-docker
```

## Workflow Examples

### After Re-authenticating Claude
```bash
# Re-authenticate locally
claude auth

# Sync to server
./sync-claude-auth.sh
```

### Continuous Development
```bash
# Start file watcher in background
./watch-and-sync.sh &

# Now any changes to Claude settings auto-sync
```

### CI/CD Integration
```bash
# Add to your deployment script
./sync-claude-auth.sh --quiet
```

## Troubleshooting

### Permission Denied
```bash
# Ensure scripts are executable
chmod +x *.sh
```

### SSH Connection Issues
```bash
# Test SSH connection
ssh -p 22 ubuntu@152.69.169.140 "echo 'Connected!'"
```

### Container Not Found
- Ensure container name matches in Coolify
- Check if container is running: `docker ps`

## Security Notes

- 🔒 Uses SSH for secure transfer
- 🔐 Credentials never stored in git
- 🛡️ Temporary files cleaned up automatically
- ⚠️ Keep `.env.sync.local` in `.gitignore`

## Advanced Usage

### GitHub Action for Auto-Deploy
```yaml
name: Deploy Claude Docker
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Sync Claude Auth
        env:
          CLAUDE_REMOTE_HOST: ${{ secrets.REMOTE_HOST }}
        run: |
          # Add SSH key
          echo "${{ secrets.SSH_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          
          # Copy auth from secrets
          echo "${{ secrets.CLAUDE_JSON }}" > ~/.claude.json
          
          # Run sync
          ./sync-claude-auth.sh --quiet
```