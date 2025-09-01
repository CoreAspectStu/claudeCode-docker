# 🚀 Claude Code Docker on Coolify - Simple Setup Guide

> **Time Required**: 15-20 minutes  
> **Difficulty**: Easy (just follow the steps!)  
> **Platform**: Windows (with instructions for Mac/Linux)

---

## 📋 Quick Checklist (What You Need)

Before starting, make sure you have:

- [ ] **Windows PC** with PowerShell or Git Bash
- [ ] **Node.js** installed ([Download here](https://nodejs.org/))
- [ ] **Anthropic Account** (Sign up at [claude.ai](https://claude.ai))
- [ ] **Coolify Server** access (you have this at 152.69.169.140)
- [ ] **SSH access** to your Coolify server
- [ ] **GitHub account** (for storing the code)

---

## 🎯 Part 1: Local Setup (10 minutes)

### Step 1: Install Claude Code Locally

Open PowerShell (or Terminal) and run:

```powershell
# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Authenticate with Anthropic
claude auth
```

**What happens**: A browser window opens → Log in to Claude → Authorization complete!

### Step 2: Verify Authentication

```powershell
# Check that these files exist
dir ~\.claude.json
dir ~\.claude\
```

✅ If you see the files, authentication worked!

### Step 3: Clone the Repository

```powershell
# Clone your forked repository
git clone https://github.com/CoreAspectStu/claudeCode-docker
cd claudeCode-docker
```

### Step 4: Configure Environment Variables

```powershell
# Copy the example file
copy .env.example .env

# Open in notepad to edit
notepad .env
```

**Add these values** (minimum required):

```env
# Git Configuration (REQUIRED)
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=your.email@example.com

# Optional: SMS Notifications
TWILIO_ACCOUNT_SID=skip_for_now
TWILIO_AUTH_TOKEN=skip_for_now
TWILIO_FROM_NUMBER=skip_for_now
TWILIO_TO_NUMBER=skip_for_now
```

**Save and close** the file.

---

## 🌐 Part 2: Deploy to Coolify (5 minutes)

### Step 1: Access Coolify Dashboard

1. Open your browser
2. Go to your Coolify URL (you should have this)
3. Log in with your credentials

### Step 2: Navigate to Your Project

1. Click on **Projects** in the sidebar
2. Find **"claudeCode-docker"** project (we created this earlier)
3. Click on it to open

### Step 3: Create New Application

1. Click **"+ New Resource"**
2. Select **"Public Repository"**
3. Fill in these details:

```
Repository URL: https://github.com/CoreAspectStu/claudeCode-docker
Branch: main
Build Pack: Docker Compose
Server: n8n-v1 (152.69.169.140)
```

4. Click **"Continue"**

### Step 4: Configure Application Settings

1. **General Tab**:
   - Name: `claude-code-docker`
   - Leave other defaults

2. **Environment Variables Tab**:
   Click "+ Add" and add these:

   ```
   GIT_USER_NAME=Your Name
   GIT_USER_EMAIL=your.email@example.com
   ```

3. **Advanced Tab**:
   - Leave defaults for now

### Step 5: Deploy!

1. Click **"Deploy"** button
2. Watch the logs - it will:
   - Clone repository ✓
   - Build Docker image ✓
   - Start container ✓

⏱️ **Wait time**: 5-10 minutes for first build

---

## 🔄 Part 3: Sync Your Authentication (5 minutes)

### Step 1: Prepare for Sync

In PowerShell, navigate to your cloned repo:

```powershell
cd claudeCode-docker
```

### Step 2: Run Initial Sync

#### For Windows Users:

**Option A: Double-click Method**
1. Open File Explorer
2. Navigate to `claudeCode-docker` folder
3. Double-click `sync-claude-auth.bat`
4. Follow the prompts

**Option B: PowerShell Method**
```powershell
# Make sure you're in the claudeCode-docker directory
.\sync-claude-auth.ps1
```

**Option C: Git Bash Method** (if you have Git installed)
```bash
./sync-claude-auth.sh
```

### Step 3: What the Sync Does

The script will:
1. ✅ Check your local Claude authentication
2. ✅ Connect to your Coolify server via SSH
3. ✅ Copy authentication files securely
4. ✅ Update the Docker container
5. ✅ Fix file permissions

### Step 4: Set Up Auto-Sync (Optional but Recommended)

When prompted "Would you like to set up automatic sync?", type **`y`**

This creates:
- Scheduled task (Windows) that syncs daily
- Git hook that syncs after commits
- File watcher for real-time sync (optional)

---

## ✅ Part 4: Verify Everything Works

### Step 1: Check Coolify Status

1. Go back to Coolify dashboard
2. Check your application status:
   - Should show **"Running"** with green indicator
   - If not, check logs for errors

### Step 2: Test Claude Access

SSH into your server and test:

```bash
# SSH to your server
ssh ubuntu@152.69.169.140

# Check container is running
docker ps | grep claude-code

# Test Claude inside container
docker exec -it claude-code-docker claude --version
```

### Step 3: Check Authentication

```bash
# Verify auth files are in place
docker exec -it claude-code-docker ls -la /home/claude-user/.claude.json
docker exec -it claude-code-docker ls -la /home/claude-user/.claude/
```

---

## 🔧 Troubleshooting

### Problem: "Remote branch main not found"
**Solution**: Already fixed! We created the main branch.

### Problem: "docker-compose.yaml not found"
**Solution**: Already fixed! We added both .yml and .yaml files.

### Problem: "Permission denied" during sync
**Solution**:
```powershell
# Generate SSH key if you haven't
ssh-keygen -t rsa -b 4096

# Copy to server
type ~\.ssh\id_rsa.pub | ssh ubuntu@152.69.169.140 "cat >> ~/.ssh/authorized_keys"
```

### Problem: "Container not running"
**Solution**: Check Coolify logs and restart deployment.

### Problem: "Claude authentication failed"
**Solution**:
1. Re-authenticate locally: `claude auth`
2. Run sync again: `.\sync-claude-auth.ps1`

---

## 🎉 Success! What Now?

Your Claude Code Docker is now:
- ✅ **Deployed** on Coolify
- ✅ **Authenticated** with your Claude account
- ✅ **Auto-syncing** when you make changes
- ✅ **Ready to use** for AI coding tasks

### Using Claude in Projects

1. **SSH into your server**:
   ```bash
   ssh ubuntu@152.69.169.140
   ```

2. **Enter the container**:
   ```bash
   docker exec -it claude-code-docker bash
   ```

3. **Navigate to workspace and use Claude**:
   ```bash
   cd /workspace
   claude "Help me build a REST API"
   ```

---

## 📚 Quick Reference

### Important Files
- **Local Auth**: `~/.claude.json` and `~/.claude/`
- **Sync Script**: `sync-claude-auth.ps1` (Windows) or `sync-claude-auth.sh` (Mac/Linux)
- **Environment**: `.env` file in repository
- **Docker Compose**: `docker-compose.yaml`

### Key Commands
```powershell
# Re-authenticate Claude
claude auth

# Sync to server
.\sync-claude-auth.ps1

# Check container logs
ssh ubuntu@152.69.169.140 "docker logs claude-code-docker"

# Restart container
ssh ubuntu@152.69.169.140 "docker restart claude-code-docker"
```

### Useful Links
- [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)
- [Coolify Docs](https://coolify.io/docs)
- [Repository](https://github.com/CoreAspectStu/claudeCode-docker)

---

## 🆘 Need Help?

1. **Check the logs** in Coolify dashboard
2. **Review this guide** - did you miss a step?
3. **Check SECURITY.md** for security questions
4. **Open an issue** on GitHub if you're stuck

---

## 🔐 Security Notes

- **Never commit** `.claude.json` to git
- **Use SSH keys** instead of passwords
- **Keep your local machine** secure and locked
- **Rotate tokens** periodically (monthly recommended)
- See `SECURITY.md` for full security guide

---

**Last Updated**: August 2025  
**Guide Version**: 1.0  
**Tested On**: Windows 11, Coolify v4.x