# Security Considerations for Claude Auth Sync

## 🔐 Security Overview

This document outlines the security measures and best practices for syncing Claude authentication to your Coolify server.

## Security Measures Implemented

### 1. **Transport Security**
- ✅ **SSH Encryption**: All transfers use SSH (port 22) with encrypted connections
- ✅ **No Plain Text**: Authentication files are never transmitted in plain text
- ✅ **Temporary Files**: Server-side temp files are deleted immediately after use

### 2. **Authentication Security**
- ✅ **SSH Key Authentication**: Uses your existing SSH keys (no passwords in scripts)
- ✅ **No Credential Storage**: Scripts don't store any credentials
- ✅ **Local Authentication**: Claude tokens stay on your machine and server only

### 3. **File Security**
- ✅ **Proper Permissions**: Files are chowned to correct user in container
- ✅ **No Git Storage**: `.claude.json` and auth files are in `.gitignore`
- ✅ **Isolated Container**: Auth runs inside Docker container with limited access

## 🛡️ Best Practices

### For Maximum Security:

1. **Use SSH Keys** (not passwords)
   ```bash
   # Generate dedicated key for Coolify
   ssh-keygen -t ed25519 -f ~/.ssh/coolify_key -C "coolify-deploy"
   
   # Add to server
   ssh-copy-id -i ~/.ssh/coolify_key.pub ubuntu@152.69.169.140
   ```

2. **Restrict SSH Key Permissions**
   ```bash
   # On server, limit what the deployment key can do
   # Edit ~/.ssh/authorized_keys and add restrictions:
   command="/usr/local/bin/deploy-only.sh",no-port-forwarding,no-X11-forwarding ssh-ed25519 AAAA...
   ```

3. **Use Environment-Specific Auth**
   - Keep production auth separate from development
   - Use different Claude accounts for different environments
   - Rotate tokens periodically

4. **Secure Your Local Machine**
   - Use full disk encryption
   - Lock screen when away
   - Keep OS and software updated

5. **Network Security**
   - Use VPN when on public WiFi
   - Consider IP whitelisting on server
   - Use fail2ban on server for SSH protection

## 🚨 Security Warnings

### ⚠️ NEVER DO THIS:
- ❌ Don't commit `.claude.json` to git
- ❌ Don't share your Claude authentication
- ❌ Don't use password authentication for SSH
- ❌ Don't run sync scripts with sudo unnecessarily
- ❌ Don't store credentials in environment variables in .bashrc

### 🔴 High-Risk Scenarios:
1. **Shared Servers**: If others have root access, they can access container files
2. **Public Repositories**: Never push auth files to public repos
3. **Compromised Local Machine**: Attacker gets your auth tokens
4. **Man-in-the-Middle**: Use verified host keys for SSH

## 🔒 Enhanced Security Setup (Optional)

### Option 1: Encrypted Vault Storage
```bash
# Use HashiCorp Vault or similar
vault kv put secret/claude auth=@~/.claude.json

# Retrieve in deployment
vault kv get -field=auth secret/claude > ~/.claude.json
```

### Option 2: Use GitHub Secrets (for CI/CD)
```yaml
# .github/workflows/deploy.yml
- name: Setup Claude Auth
  run: |
    echo "${{ secrets.CLAUDE_AUTH }}" | base64 -d > ~/.claude.json
    ./sync-claude-auth.sh --quiet
```

### Option 3: AWS Secrets Manager
```bash
# Store secret
aws secretsmanager create-secret --name claude-auth --secret-string file://~/.claude.json

# Retrieve in deployment
aws secretsmanager get-secret-value --secret-id claude-auth --query SecretString --output text > ~/.claude.json
```

## 🔍 Security Audit Checklist

- [ ] SSH keys have proper permissions (600)
- [ ] No auth files in git history
- [ ] Server has fail2ban configured
- [ ] Docker container runs as non-root
- [ ] Firewall configured on server
- [ ] Regular security updates applied
- [ ] Auth tokens rotated periodically
- [ ] Logs monitored for suspicious activity

## 📊 Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| SSH Key Compromise | Low | High | Use key passphrase, rotate keys |
| Local Machine Compromise | Medium | High | Full disk encryption, screen lock |
| Network Interception | Low | Medium | SSH encryption, VPN |
| Server Compromise | Low | High | Regular updates, monitoring |
| Container Escape | Very Low | High | Keep Docker updated |

## 🆘 Incident Response

### If Claude Auth is Compromised:
1. **Immediately revoke access** in Claude dashboard
2. **Generate new authentication** locally
3. **Update all deployments** with new auth
4. **Audit logs** for unauthorized usage
5. **Report to Anthropic** if suspicious activity

## 📝 Security Recommendations Summary

### Minimum Security (Required):
- ✅ Use SSH for transfers
- ✅ Keep auth files out of git
- ✅ Use SSH keys (not passwords)

### Recommended Security:
- ✅ Dedicated SSH key for deployments
- ✅ Regular token rotation
- ✅ Server firewall and fail2ban
- ✅ Monitoring and alerts

### Maximum Security (Paranoid Mode):
- ✅ Vault/secrets manager integration
- ✅ Hardware security keys
- ✅ Network segmentation
- ✅ Audit logging everything
- ✅ Separate accounts per environment

## 📚 Additional Resources

- [SSH Security Best Practices](https://www.ssh.com/academy/ssh/security)
- [Docker Security Guide](https://docs.docker.com/engine/security/)
- [Anthropic Security](https://www.anthropic.com/security)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)