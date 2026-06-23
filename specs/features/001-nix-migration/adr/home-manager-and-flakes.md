# ADR: Home Manager and Flakes

## Context

現在のchezmoi管理対象はユーザーのホーム配下のdotfilesであり、OSレベルの設定は含まれていない。

対象PCはmacOSの`aarch64-darwin`で揃っている。現時点ではmacOS defaults、Homebrew、LaunchDaemon、Nix daemon、`/etc`配下などをこのリポジトリで管理しない。

## Decision

- 第一段階ではHome Manager単体で移行する。
- nix-darwinは導入しない。
- Flakesを採用し、`flake.nix`と`flake.lock`でNix inputsとHome Manager outputを管理する。
- 公開flake outputは`homeConfigurations."kakudo"`の1つにする。

## Rationale

- 既存の管理対象はHome Managerの責務に収まる。
- nix-darwinを入れるとmacOSシステム設定まで管理できるが、今回のfeatureに対して導入範囲が広がる。
- Flakesにより、`nixpkgs`と`home-manager`の入力バージョンを`flake.lock`で固定できる。
- 対象systemが`aarch64-darwin`のみなので、初期構成ではhost/profile別outputを作らなくてよい。

## Consequences

- macOSのシステム設定やHomebrew caskは第一段階では対象外にする。
- Home Manager moduleで管理できるGUIアプリは、アプリ本体もHome Managerで管理する。
- NixでinstallできるCLI toolやアプリ依存は、Home Managerの`home.packages`または`programs.*` moduleで管理する。
- `flake.lock`はコミットし、複数PCで同じ入力バージョンを使う。
- 将来、macOS defaults、フォント、Homebrew cask、Touch ID sudo、Dock設定などを管理したくなった場合はnix-darwin導入を再検討する。

## References

- https://nix.dev/concepts/flakes
- https://nix-community.github.io/home-manager/
- https://github.com/nix-darwin/nix-darwin
