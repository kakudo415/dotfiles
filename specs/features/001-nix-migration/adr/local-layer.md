# ADR: Local Layer

## Context

このリポジトリは公開リポジトリであり、職場PC専用の情報やファイルを含めてはいけない。

FlakesではGitリポジトリ内の未追跡ファイルが評価対象に入らない。また、Nix storeは原則としてローカルユーザーから読めるため、平文の秘密をNix式へ埋め込まない。

## Decision

公開リポジトリは共通設定だけを管理し、PC固有設定や秘匿情報はGit管理外のlocal layerで扱う。

local layerの標準パスは`$XDG_CONFIG_HOME/local/`とする。`XDG_CONFIG_HOME`が未設定の場合は`~/.config/local/`を使う。

公開Home Manager設定は、local fileをNix評価時に読まない。shellやGitなどinclude機能を持つツールは実行時にlocal fileを参照する。JSON設定ファイルを持つツールは、Home Managerのactivation時に共通JSONとlocal JSONをmergeして最終ファイルを生成する。JSON merge ruleは、まずlocal側がcommon側を上書きする方式にする。配列もlocal側で上書きする。

## Rationale

- 公開リポジトリにも`flake.lock`にも職場情報が入らない。
- Nix評価時にローカルsecretを読まないため、Nix storeへ平文が混入しにくい。
- Git、shell、sshなど、実行時includeを持つツールと相性がよい。
- 個人PC/職場PC profileやPC固有host moduleを作らずに、共通設定とlocal設定の2-layer構成で運用できる。
- include機能を持たないJSONアプリでも、activation-time mergeにより2-layer構成を維持できる。

## Alternatives

### sops-nix

長所:

- 暗号化されたsecretをGitで履歴管理できる。
- YAML/JSONなど構造化secretを扱いやすい。
- 複数PC・複数鍵・チーム運用へ拡張しやすい。

短所:

- 公開リポジトリに、暗号化済みとはいえ職場設定の存在やファイル名が残る。
- 鍵管理、rekey、復号失敗時の運用が増える。
- 今回の「職場PCでのみ参照するファイルはこのリポジトリに漏れないこと」という要件には合いにくい。

### agenix

長所:

- SSH keyベースで小さく始めやすい。
- Nix設定から`config.age.secrets.<name>.path`を参照できる。
- 平文をNix評価へ戻さず、実行時pathとして扱う設計と相性がよい。

短所:

- sops-nix同様、暗号化済みsecretファイルの存在はリポジトリに残る。
- Home Manager on Darwinでは復号先が一時ディレクトリになるため、永続ファイルを期待するツールでは設計確認が必要。
- JSON/YAMLの複数key管理はsops-nixの方が扱いやすい。

### private flake/private module

長所:

- 職場固有のNix moduleやpackage listまで宣言的に管理できる。
- 公開リポジトリと職場情報の境界が明確。

短所:

- 公開flakeからprivate flakeをinput参照すると`flake.lock`にURLやrevが残る。
- 公開設定とprivate設定の合成手順が増える。
- 職場PCの情報を外に出さない要件では、private flakeの参照自体も公開リポジトリに入れない運用が必要。

## Consequences

- local fileの中身はNixで再現・検証されない。
- 新しいPCではlocal fileを別途作る必要がある。
- local JSONの構文エラーはNix評価時ではなくactivation時に検出される。
- 配列の連結が必要なJSON設定が出た場合は、ツールごとにmerge ruleを追加する必要がある。
- secretをGitで暗号化管理したい要件が出た場合は、sops-nixまたはagenixを再検討する。

## References

- https://github.com/Mic92/sops-nix
- https://github.com/ryantm/agenix
