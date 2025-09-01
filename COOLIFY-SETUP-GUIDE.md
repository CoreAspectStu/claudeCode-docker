# Claude Code Docker on Coolify - Setup Guide

> **Note**: For detailed setup instructions with your specific server configuration, please refer to your private documentation repository.

## Overview

This guide helps you deploy Claude Code Docker to your Coolify instance.

## Prerequisites

- Node.js installed locally
- Anthropic account (claude.ai)
- Coolify server access
- SSH access to your server
- GitHub account

## Quick Start

### 1. Local Setup

```bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Authenticate
claude auth

# Clone this repository
git clone https://github.com/CoreAspectStu/claudeCode-docker
cd claudeCode-docker

# Configure environment
cp .env.example .env
# Edit .env with your values
```

### 2. Deploy to Coolify

1. Access your Coolify dashboard
2. Create new application from public repository
3. Use this repository URL with branch `main`
4. Select Docker Compose as build pack
5. Configure environment variables
6. Deploy

### 3. Sync Authentication

Use the provided sync scripts to transfer your Claude authentication to the server:

- **Windows**: `sync-claude-auth.ps1` or `sync-claude-auth.bat`
- **Mac/Linux**: `sync-claude-auth.sh`

### 4. Verify

```bash
# SSH to your server
ssh your-server

# Check container
docker ps | grep claude-code

# Test Claude
docker exec -it claude-code-docker claude --version
```

## Documentation

- [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)
- [Coolify Docs](https://coolify.io/docs)
- [MCP Servers](MCP_SERVERS.md)

## Security

- Never commit `.claude.json` or `.env` files
- Use SSH keys instead of passwords
- Keep authentication tokens secure
- See [SECURITY.md](SECURITY.md) for details

## Support

For issues with:
- **Claude Code**: Check Anthropic documentation
- **Docker**: Check container logs
- **Coolify**: Check deployment logs

---

*For private server-specific configuration, maintain a separate private repository.*