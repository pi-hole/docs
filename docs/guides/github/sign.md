# Signing Git Commits with SSH Keys

## Why Sign Commits?

Signing commits provides:

- **Authentication**: Proves the commit actually came from you
- **Integrity**: Ensures the commit content hasn't been tampered with
- **Trust**: GitHub displays a "Verified" badge for signed commits
- **Security**: Protects against commit spoofing attacks

## Prerequisites

- An SSH key pair (if you don't have one, generate with `ssh-keygen -t ed25519 -C "your_email@example.com"`)
- SSH key added to your GitHub account

## Setup Instructions

### 1. Configure Git to Use SSH Signing

```bash
# Set SSH as the signing format
git config --global gpg.format ssh

# Specify your SSH public key for signing
git config --global user.signingkey /PATH/TO/.SSH/KEY.PUB

# Optional: Enable automatic signing for all commits
git config --global commit.gpgsign true
```

### 2. Add SSH Key to GitHub

1. Copy your SSH public key: `/PATH/TO/.SSH/KEY.PUB`
2. Go to GitHub → Settings → SSH and GPG keys
3. Click "New SSH key"
4. Set Key type to "Signing Key"
5. Paste your public key and save

### 3. Sign Commits

```bash
# Sign a single commit
git commit -S -m "Your commit message"

# If auto-signing is enabled, just commit normally
git commit -m "Your commit message"
```

## Verification

- On GitHub: Look for the "Verified" badge next to your commits
- Locally: `git log --show-signature` displays signature information


## Notes

- SSH signing requires Git 2.34+ and GitHub support
- Your SSH key must be added as a "Signing Key" type in GitHub, not just an authentication key
