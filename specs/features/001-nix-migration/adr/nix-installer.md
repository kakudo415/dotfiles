# ADR: Nix Installer

## Context

Nixはまだ対象PCに導入していない。対象はmacOSの`aarch64-darwin`で、第一段階ではHome Manager単体でdotfilesを管理する。

候補:

- 公式Nix installer
- Determinate Nix
- Lix

## Decision

公式Nix installerを採用する。

macOSでは公式のmulti-user installationを使う。

## Rationale

- 上流の標準構成で、Nixの公式ドキュメントと差分が少ない。
- Home ManagerやNix flakesの標準的な情報と合わせやすい。
- 余分な商用サービスや独自daemonに依存しない。
- 今回の目的はdotfiles移行であり、導入直後は学習・切り分け・将来の移行を単純に保つ方が重要。

## Alternatives

### Determinate Nix

長所:

- macOS workstationでの導入体験がよい。
- uninstallや修復導線が整っている。
- Flakes中心の開発体験に寄せられている。
- Determinate NixdによるmacOS Keychain由来の証明書連携やGCなどの運用補助がある。
- organization運用、private flakes、cache連携へ拡張しやすい。

短所:

- 上流Nixそのものではなく、商用ベンダーのdistributionを採用することになる。
- FlakeHub等の周辺サービス導線があり、単体dotfiles用途では過剰になり得る。
- 職場PCで利用する場合、会社のポリシー上サードパーティdaemonや外部サービス連携が問題にならないか確認が必要。

### Lix

長所:

- Nix互換のまま、エラーメッセージやREPLなどの使い勝手改善を得られる可能性がある。
- community-drivenな実装を選べる。
- Flakes利用を認めつつ、将来的にFlakes以外の体験改善も目指している。

短所:

- 上流Nixではないため、問題切り分け時に「Nix固有かLix固有か」を見る必要がある。
- 初回導入者にとっては、公式Nixのドキュメントとの差分が増える。
- 職場PCで使う場合は、非公式実装の採用可否を確認する必要がある。

## Consequences

- Specの導入手順は公式Nix installer前提にする。
- Flakesなど必要なexperimental featureは公式Nixの設定として明示的に有効化する。
- macOSで公式installer由来の運用負荷が問題になった場合は、Determinate Nixへの移行を再検討する。

## References

- https://nixos.org/download/
- https://docs.determinate.systems/
- https://lix.systems/install/
- https://lix.systems/about/
