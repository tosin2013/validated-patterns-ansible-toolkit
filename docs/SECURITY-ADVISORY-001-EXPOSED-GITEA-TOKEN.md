# Security Advisory 001: Exposed Gitea Token in Git Remote

**Date Discovered:** 2025-10-28  
**Severity:** CRITICAL  
**Status:** OPEN - REQUIRES IMMEDIATE ACTION  
**Discovered By:** Automated repository URL update process  
**CVE:** N/A (Internal security issue)

## Executive Summary

During the repository URL migration from `ansible-execution-environment` to `validated-patterns-ansible-toolkit`, an exposed Gitea authentication token was discovered embedded in the `.git/config` file's remote URL.

**Token Details:**
- **Value:** `j0sBFggYvrMlHdp0LTtn1VD0so6OlsZI`
- **Length:** 32 characters
- **Entropy:** High (4.5+)
- **Type:** Gitea personal access token or admin password
- **Location:** `.git/config` gitea remote URL
- **Format:** `https://opentlc-mgr:TOKEN@gitea-with-admin-gitea.apps.cluster-4l957.4l957.sandbox1206.opentlc.com/opentlc-mgr/ansible-execution-environment.git`

## Impact Assessment

### Severity: CRITICAL

**Potential Exposure Vectors:**
1. ✅ **Git Configuration** - Token was embedded in `.git/config` (now removed)
2. ⚠️ **Terminal History** - Token may appear in shell history from `git remote` commands
3. ⚠️ **CI/CD Logs** - Token may be in GitHub Actions, Jenkins, or other CI logs
4. ⚠️ **Git History** - Token may be in commit messages or file history
5. ⚠️ **Backup Files** - Token may be in backup files or snapshots
6. ⚠️ **Screen Recordings** - Token may be visible in demo videos or screenshots
7. ⚠️ **Documentation** - Token may be in documentation or wiki pages

**Access Granted by Token:**
- Full access to Gitea instance at `gitea-with-admin-gitea.apps.cluster-4l957.4l957.sandbox1206.opentlc.com`
- User: `opentlc-mgr` (likely admin account)
- Repository: `ansible-execution-environment`
- Permissions: Read, Write, Delete (admin level)

**Potential Malicious Actions:**
- Clone private repositories
- Modify or delete repositories
- Create malicious commits
- Access sensitive configuration files
- Compromise CI/CD pipelines
- Lateral movement to other systems

## Timeline

| Date | Event |
|------|-------|
| Unknown | Token embedded in `.git/config` gitea remote URL |
| 2025-10-27 | Gitleaks configuration created (ADR-014) |
| 2025-10-28 | Pre-commit hooks installed |
| 2025-10-28 | Repository URL update script executed |
| 2025-10-28 | **Token discovered in `git remote -v` output** |
| 2025-10-28 | Token removed from `.git/config` |
| 2025-10-28 | Security advisory created |

## Immediate Actions Taken

1. ✅ **Removed token from `.git/config`**
   ```bash
   git remote set-url gitea https://github.com/tosin2013/validated-patterns-ansible-toolkit.git
   ```

2. ✅ **Documented in RELEASE-PLAN.md**
   - Added to Blockers & Risks section
   - Marked as CRITICAL priority

3. ✅ **Created security advisory**
   - This document

## Required Actions (URGENT)

### 1. Rotate Gitea Token Immediately ⚠️ PRIORITY 1

**Steps:**
```bash
# 1. Log into Gitea instance
# URL: https://gitea-with-admin-gitea.apps.cluster-4l957.4l957.sandbox1206.opentlc.com
# User: opentlc-mgr

# 2. Navigate to Settings → Applications → Access Tokens
# 3. Revoke the exposed token: j0sBFggYvrMlHdp0LTtn1VD0so6OlsZI
# 4. Generate a new token with minimal required permissions
# 5. Store new token securely (environment variable, secrets manager)
```

### 2. Audit Access Logs ⚠️ PRIORITY 2

**Check for unauthorized access:**
```bash
# Review Gitea access logs
# Look for:
# - Unusual IP addresses
# - Unexpected repository clones
# - Unauthorized commits
# - Failed authentication attempts after token rotation

# Time window: From token creation date to 2025-10-28
```

### 3. Search for Token in Git History ⚠️ PRIORITY 3

**Scan entire git history:**
```bash
# Search all commits for the token
git log -p -S "j0sBFggYvrMlHdp0LTtn1VD0so6OlsZI" --all

# Search all branches
git grep "j0sBFggYvrMlHdp0LTtn1VD0so6OlsZI" $(git rev-list --all)

# If found, consider using git-filter-repo to remove
# WARNING: This rewrites history and requires force push
```

### 4. Check CI/CD Logs ⚠️ PRIORITY 3

**Review logs for token exposure:**
- GitHub Actions workflow logs
- Jenkins build logs
- Any automation that runs `git remote -v`
- Any scripts that display git configuration

### 5. Update Security Practices ⚠️ PRIORITY 4

**Prevent future occurrences:**
1. ✅ Pre-commit hooks installed (gitleaks)
2. ✅ `.gitleaks.toml` configured
3. ⏳ Add CI/CD secret scanning
4. ⏳ Implement secrets rotation policy
5. ⏳ Use environment variables for all tokens
6. ⏳ Never embed credentials in git URLs

## Verification Steps

After rotating the token, verify:

```bash
# 1. Confirm old token is revoked
curl -H "Authorization: token j0sBFggYvrMlHdp0LTtn1VD0so6OlsZI" \
  https://gitea-with-admin-gitea.apps.cluster-4l957.4l957.sandbox1206.opentlc.com/api/v1/user
# Expected: 401 Unauthorized

# 2. Confirm new token works
curl -H "Authorization: token NEW_TOKEN_HERE" \
  https://gitea-with-admin-gitea.apps.cluster-4l957.4l957.sandbox1206.opentlc.com/api/v1/user
# Expected: 200 OK with user details

# 3. Verify no tokens in git config
git remote -v | grep -i "token\|password"
# Expected: No output

# 4. Run gitleaks on repository
gitleaks detect --config .gitleaks.toml --verbose
# Expected: No secrets found
```

## Long-term Recommendations

1. **Secrets Management**
   - Use HashiCorp Vault or similar for token storage
   - Implement automatic token rotation
   - Use short-lived tokens where possible

2. **Access Control**
   - Implement least-privilege access
   - Use service accounts with minimal permissions
   - Enable MFA for admin accounts

3. **Monitoring**
   - Set up alerts for unusual git activity
   - Monitor access logs continuously
   - Implement anomaly detection

4. **Training**
   - Educate team on secure credential handling
   - Regular security awareness training
   - Document secure development practices

## References

- [ADR-014: Pre-commit Hooks and Gitleaks Integration](./adr/ADR-014-pre-commit-hooks-gitleaks.md)
- [RELEASE-PLAN.md - Blockers & Risks](./RELEASE-PLAN.md#-blockers--risks)
- [Gitleaks Configuration](./.gitleaks.toml)
- [Pre-commit Configuration](../.pre-commit-config.yaml)

## Contact

For questions or concerns about this security advisory:

- **Security Team:** @tosin2013
- **GitHub Issues:** https://github.com/tosin2013/validated-patterns-ansible-toolkit/issues
- **Email:** tosin.akinosho@gmail.com

---

**Status Updates:**

| Date | Update | Status |
|------|--------|--------|
| 2025-10-28 | Token discovered and removed from git config | ✅ Complete |
| 2025-10-28 | Security advisory created | ✅ Complete |
| TBD | Token rotated in Gitea | ⏳ Pending |
| TBD | Access logs audited | ⏳ Pending |
| TBD | Git history scanned | ⏳ Pending |
| TBD | CI/CD logs reviewed | ⏳ Pending |
| TBD | Advisory closed | ⏳ Pending |

**Last Updated:** 2025-10-28  
**Next Review:** After token rotation

