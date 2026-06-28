# dotfiles

dotfiles for kakudo415, managed by Nix Flakes and Home Manager.

## Setup

### Bootstrap

Install Nix first. On macOS, the official installer performs a multi-user
installation by default.

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

Restart the shell after installation, or load the Nix daemon profile script.

```sh
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Enable the `nix-command` and `flakes` experimental features. If
`~/.config/nix/nix.conf` already exists, merge this setting into the existing
file.

```nix
experimental-features = nix-command flakes
```

### First Apply

Use Home Manager from its release flake for the first activation. This does not
require `home-manager` to already be installed in the user environment. Existing
files are backed up with a date-based extension, such as `backup-20260628`.

```sh
nix run github:nix-community/home-manager/release-26.05 -- switch --flake .#kakudo -b "backup-$(date +%Y%m%d)"
```

### Daily Apply

After the first successful activation, this configuration installs the
`home-manager` command via `programs.home-manager.enable`.

```sh
home-manager switch --flake .#kakudo
```

You can also keep using the first-apply command for an explicitly pinned Home
Manager runner.

### Update

Update flake inputs before applying the refreshed configuration.

```sh
nix flake update
home-manager switch --flake .#kakudo
```

## Git

### Local Config

Git reads `$XDG_CONFIG_HOME/git/config.local` after the Home Manager generated
config. Use it for machine-local settings that should not be committed to this
repository. This file is optional; GPG signing works without `user.signingKey`
when GnuPG can select a secret key that matches the Git author email.

```ini
[url "git@github.com:"]
	insteadOf = https://github.com/
```

### GPG Signing

Git commit and tag signing are enabled by default. Home Manager installs and
configures GnuPG, gpg-agent, and pinentry-mac, but it does not create or upload
GPG keys.

Check whether a signing-capable secret key already exists for the Git email
address.

```sh
gpg --list-secret-keys --keyid-format=long 31888089+kakudo415@users.noreply.github.com
```

If no suitable key exists, create one. Use `31888089+kakudo415@users.noreply.github.com`
as the email address.

```sh
gpg --full-generate-key
```

Export the public key and register it in GitHub Settings > SSH and GPG keys.
Replace `KEY_ID` with the long key ID shown by `gpg --list-secret-keys`.

```sh
gpg --armor --export KEY_ID
```

After the key is registered, verify local signing.

```sh
git commit --allow-empty -m "Verify GPG signing"
git log --show-signature -1
```
