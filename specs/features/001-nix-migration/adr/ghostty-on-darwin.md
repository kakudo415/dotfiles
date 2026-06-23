# ADR: DarwinでのGhostty管理

## Context

最初のHome Manager build検証で、nixpkgs `26.05` の
`ghostty-1.3.1` は `aarch64-darwin` で利用不可であることが分かった。

当初の仕様では、`programs.ghostty.enable = true` を使い、Home Manager
moduleでアプリ本体と設定の両方を管理する方針だった。

しかし、このmoduleを有効化するとGhostty packageの評価が必要になり、
nixpkgsは対象platformである`aarch64-darwin`向けの評価を拒否する。

## Decision

第一段階の移行では、`aarch64-darwin`上のGhosttyアプリ本体をHome
Managerでinstallしない。

既存のGhostty設定は、Home Managerから`$XDG_CONFIG_HOME/ghostty/config`
を生成することで宣言的に管理する。アプリ本体のinstallは、固定している
release系のnixpkgsでGhosttyが`aarch64-darwin`に対応するまで、または
このリポジトリでより広いmacOSアプリ管理レイヤーを導入するまで、この
リポジトリの管理対象外にする。

`programs.ghostty.package = null`による暗黙のfallbackは使わない。現在の
固定platformではHome Managerがアプリ本体を管理できないため、この段階で
moduleを有効化すると管理実態と設定上の意味がずれる。

## Consequences

- `nix flake check --impure`を`aarch64-darwin`で評価できる。
- Ghostty設定は引き続きHome Managerで生成される。
- Ghostty.app本体は当面、別手段でinstallする必要がある。
- nixpkgsがGhosttyを`aarch64-darwin`向けに提供した場合、または
  nix-darwin/Homebrewによるアプリ管理をこのリポジトリへ導入する場合は、
  このADRを見直す。
