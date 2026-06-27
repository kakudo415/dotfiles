# dotfiles

dotfiles for kakudo415, managed by Nix Flakes and Home Manager.

## Bootstrap

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

## First Apply

Use Home Manager from its release flake for the first activation. This does not
require `home-manager` to already be installed in the user environment. Existing
files are backed up with a date-based extension, such as `backup-20260628`.

```sh
nix run github:nix-community/home-manager/release-26.05 -- switch --flake .#kakudo -b "backup-$(date +%Y%m%d)"
```

## Daily Apply

After the first successful activation, this configuration installs the
`home-manager` command via `programs.home-manager.enable`.

```sh
home-manager switch --flake .#kakudo
```

You can also keep using the first-apply command for an explicitly pinned Home
Manager runner.

## Verify

```sh
nix flake check
nix build .#homeConfigurations.kakudo.activationPackage
nix run github:nix-community/home-manager/release-26.05 -- build --flake .#kakudo
```
