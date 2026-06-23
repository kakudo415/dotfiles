# dotfiles

dotfiles for kakudo415, managed by Nix flakes and Home Manager.

## Requirements

- macOS on `aarch64-darwin`
- Official Nix installer
- Flakes enabled with `experimental-features = nix-command flakes`

This repository intentionally uses Home Manager without nix-darwin. Local,
machine-specific, and secret settings live outside Git under:

```sh
${XDG_CONFIG_HOME:-$HOME/.config}/local
```

## First Apply

Generate or update `flake.lock` after installing Nix:

```sh
nix flake lock
```

Apply the configuration through the Home Manager CLI pinned by the flake:

```sh
nix run .#home-manager -- switch --flake .#kakudo --impure
```

`--impure` is required because `home.username` and `home.homeDirectory` are
read from `USER` and `HOME`, keeping machine-specific values out of the public
repository.

## Regular Apply

After Home Manager is installed into the profile:

```sh
home-manager switch --flake .#kakudo --impure
```

## Local Layer

Home Manager activation creates these files if they are missing:

```text
$XDG_CONFIG_HOME/local/
├── shell
│   ├── bashrc
│   └── zshrc
├── git
│   └── config
├── claude
│   └── settings.json
└── README.local.md
```

Put GPG signing keys, work Git settings, credential helpers, local PATH
changes, and other machine-specific settings in this local layer. The public
flake does not read local files during Nix evaluation.

Claude settings are merged at activation time. Common settings are generated
from Nix, local JSON overrides them, and arrays are replaced by the local value.

## Validation

```sh
nix flake check --impure
nix run .#home-manager -- build --flake .#kakudo --impure
```

## Rollback

List generations:

```sh
home-manager generations
```

Activate an older generation:

```sh
/nix/store/<generation-path>/activate
```
