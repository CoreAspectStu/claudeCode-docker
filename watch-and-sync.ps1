# File Watcher for Windows - Auto-sync Claude auth on changes

# Configuration
$RemoteHost = if ($env:CLAUDE_REMOTE_HOST) { $env:CLAUDE_REMOTE_HOST } else { "ubuntu@152.69.169.140" }
$claudeJsonPath = "$env:USERPROFILE\.claude.json"
$claudeDirPath = "$env:USERPROFILE\.claude"

Write-Host "👁️ Claude Auth File Watcher (Windows)" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host "Watching for changes in:"
Write-Host "  - $claudeJsonPath"
Write-Host "  - $claudeDirPath"
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Create FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $env:USERPROFILE
$watcher.Filter = ".claude*"
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Define action for file changes
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType
    
    Write-Host "📝 Change detected: $changeType - $path" -ForegroundColor Yellow
    Write-Host "Syncing..." -ForegroundColor Yellow
    
    # Run sync script
    & "$PSScriptRoot\sync-claude-auth.ps1" -NoPrompt
    
    Write-Host "✅ Sync complete" -ForegroundColor Green
    Write-Host ""
}

# Register event handlers
Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action
Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action
Register-ObjectEvent -InputObject $watcher -EventName "Deleted" -Action $action

# Keep script running
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    # Clean up
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Write-Host "Watcher stopped." -ForegroundColor Red
}