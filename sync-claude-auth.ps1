# Claude Auth Sync Script for Windows
# Syncs local Claude authentication to remote Coolify server

# Configuration
$RemoteHost = if ($env:CLAUDE_REMOTE_HOST) { $env:CLAUDE_REMOTE_HOST } else { "ubuntu@152.69.169.140" }
$RemotePort = if ($env:CLAUDE_REMOTE_PORT) { $env:CLAUDE_REMOTE_PORT } else { "22" }
$ContainerName = if ($env:CLAUDE_CONTAINER_NAME) { $env:CLAUDE_CONTAINER_NAME } else { "claude-code-docker" }

# Colors for output
$Host.UI.RawUI.ForegroundColor = "White"

Write-Host "`n🔄 Claude Auth Sync Tool (Windows)" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Check if local Claude files exist
$claudeJsonPath = "$env:USERPROFILE\.claude.json"
$claudeDirPath = "$env:USERPROFILE\.claude"

if (-not (Test-Path $claudeJsonPath)) {
    Write-Host "❌ Error: ~/.claude.json not found" -ForegroundColor Red
    Write-Host "Please authenticate Claude Code locally first:"
    Write-Host "  npm install -g @anthropic-ai/claude-code"
    Write-Host "  claude"
    exit 1
}

if (-not (Test-Path $claudeDirPath)) {
    Write-Host "❌ Error: ~/.claude/ directory not found" -ForegroundColor Red
    Write-Host "Please run Claude Code locally first to create settings"
    exit 1
}

function Test-SSHConnection {
    Write-Host "`n🔐 Testing SSH connection..." -ForegroundColor Yellow
    try {
        ssh -p $RemotePort -o ConnectTimeout=5 $RemoteHost "echo 'Connected'"
        Write-Host "✅ SSH connection successful" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ SSH connection failed" -ForegroundColor Red
        Write-Host "Please ensure:"
        Write-Host "  1. SSH is installed (OpenSSH or Git Bash)"
        Write-Host "  2. You have SSH access to the server"
        Write-Host "  3. Your SSH key is configured"
        return $false
    }
}

function Sync-Files {
    Write-Host "`n📤 Uploading Claude authentication files..." -ForegroundColor Yellow
    
    # Create temp directory on remote
    ssh -p $RemotePort $RemoteHost "mkdir -p /tmp/claude-auth-sync"
    
    # Copy files using SCP
    scp -P $RemotePort "$claudeJsonPath" "${RemoteHost}:/tmp/claude-auth-sync/"
    scp -P $RemotePort -r "$claudeDirPath" "${RemoteHost}:/tmp/claude-auth-sync/"
    
    Write-Host "✅ Files uploaded to server" -ForegroundColor Green
}

function Update-Container {
    Write-Host "`n🐳 Updating Docker container..." -ForegroundColor Yellow
    
    $updateScript = @'
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
fi

# Clean up temp files
rm -rf /tmp/claude-auth-sync
'@
    
    ssh -p $RemotePort $RemoteHost $updateScript
    
    Write-Host "✅ Container update complete" -ForegroundColor Green
}

# Main execution
Write-Host "`n📋 Configuration:" -ForegroundColor Yellow
Write-Host "   Remote Host: $RemoteHost"
Write-Host "   Remote Port: $RemotePort"
Write-Host "   Container: $ContainerName"
Write-Host ""

$response = Read-Host "Continue? (y/n)"
if ($response -ne 'y' -and $response -ne 'Y') {
    Write-Host "Cancelled."
    exit 0
}

# Test SSH first
if (-not (Test-SSHConnection)) {
    exit 1
}

# Execute sync
Sync-Files
Update-Container

Write-Host "`n🎉 Sync complete!" -ForegroundColor Green
Write-Host "Your Claude authentication is now synced to the server."

# Ask about creating scheduled task
Write-Host "`n⏰ Would you like to create a scheduled task for auto-sync? (y/n)" -ForegroundColor Yellow
$autoSync = Read-Host
if ($autoSync -eq 'y' -or $autoSync -eq 'Y') {
    Write-Host "Creating scheduled task..." -ForegroundColor Yellow
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$PSScriptRoot\sync-claude-auth.ps1`" -NoPrompt"
    $trigger = New-ScheduledTaskTrigger -Daily -At "9:00AM"
    Register-ScheduledTask -TaskName "ClaudeAuthSync" -Action $action -Trigger $trigger -Description "Sync Claude authentication to Coolify server"
    Write-Host "✅ Scheduled task created (runs daily at 9 AM)" -ForegroundColor Green
}