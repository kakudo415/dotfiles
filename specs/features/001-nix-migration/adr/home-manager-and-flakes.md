# ADR: Home Manager and Flakes

## Context

現在のchezmoi管理対象はユーザーのホーム配下のdotfilesであり、OSレベルの設定は含まれていない。

対象PCはmacOSの`aarch64-darwin`で揃っている。現時点ではmacOS defaults、Homebrew、LaunchDaemon、Nix daemon、`/etc`配下などをこのリポジトリで管理しない。

## Decision

- 第一段階ではHome Manager単体で移行する。
- nix-darwinは導入しない。
- Flakesを採用し、`flake.nix`と`flake.lock`でNix inputsとHome Manager outputを管理する。
- `nixpkgs`と`home-manager`は`26.05` release系に揃える。
- 公開flake outputは`homeConfigurations."kakudo"`の1つにする。
- 初回適用の入口として、`apps.aarch64-darwin.home-manager`を定義する。これは`flake.lock`で固定されたHome Manager CLIを実行する。
- 通常適用は`home-manager switch --flake .#kakudo --impure`を標準にする。
- `home.stateVersion`は`26.05`に固定する。
- `home.username`と`home.homeDirectory`は、実行者の`USER`と`HOME`から取得する。

## Rationale

- 既存の管理対象はHome Managerの責務に収まる。
- nix-darwinを入れるとmacOSシステム設定まで管理できるが、今回のfeatureに対して導入範囲が広がる。
- Flakesにより、`nixpkgs`と`home-manager`の入力バージョンを`flake.lock`で固定できる。
- `nixpkgs`と`home-manager`のrelease系を揃えることで、Home Managerのrelease mismatchを避ける。
- 対象systemが`aarch64-darwin`のみなので、初期構成ではhost/profile別outputを作らなくてよい。
- `nix run .#home-manager -- switch --flake .#kakudo --impure`を初回適用に使うと、未pinの`github:nix-community/home-manager`を直接実行する必要がなく、`flake.lock`で固定されたHome Manager CLIを使える。
- `home-manager switch`はHome Managerの通常操作として自然で、世代管理やrollbackの説明とも揃う。
- `home.stateVersion`は、Home Managerのファイル配置や既定値の互換性を保つための基準であり、Nix packagesのバージョン固定ではない。通常のinput更新では変更しない。
- `home.username`と`home.homeDirectory`を公開リポジトリに固定すると、職場PCで割り当てられたユーザーIDやhome pathが外部に出る可能性がある。環境変数から取得する方式にすると、single outputを維持しつつPCごとの差分を公開リポジトリに含めずに済む。

## Consequences

- macOSのシステム設定やHomebrew caskは第一段階では対象外にする。
- Home Manager moduleで管理できるGUIアプリは、アプリ本体もHome Managerで管理する。
- NixでinstallできるCLI toolやアプリ依存は、Home Managerの`home.packages`または`programs.*` moduleで管理する。
- `flake.lock`はコミットし、複数PCで同じ入力バージョンを使う。
- `home.username`と`home.homeDirectory`を環境変数から取得するため、Home Managerのbuild/switchと`nix flake check`には`--impure`が必要になる。
- flake評価は`USER`と`HOME`に依存する。依存対象はユーザー識別情報だけに限定し、local layerの設定ファイルは評価時に読まない。
- 初回適用は`nix run .#home-manager -- switch --flake .#kakudo --impure`を使い、Home Manager導入後の通常適用は`home-manager switch --flake .#kakudo --impure`を使う。
- `home.stateVersion`を上げる場合は、Home Managerのrelease noteを確認し、必要な手動migrationを別タスクで実施する。
- 将来、macOS defaults、フォント、Homebrew cask、Touch ID sudo、Dock設定などを管理したくなった場合はnix-darwin導入を再検討する。

## References

- https://nix.dev/concepts/flakes
- https://nix-community.github.io/home-manager/
- https://github.com/nix-darwin/nix-darwin
