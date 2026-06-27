# dotfiles

dotfiles for kakudo415, managed by Nix Flakes and Home Manager.

## First Apply

Use Home Manager from its release flake for the first activation. This does not
require `home-manager` to already be installed in the user environment.

```sh
nix run github:nix-community/home-manager/release-26.05 -- switch --flake .#kakudo
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
