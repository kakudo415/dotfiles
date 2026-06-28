# Repository Refactor

## 背景

このリポジトリはNix FlakesとHome Managerでdotfilesを管理している。
現在の構成は `nix flake check` とHome Manager activation package buildで検証できる状態になっている。

一方で、Bash/ZshのaliasとGit prompt用設定、Claude Codeの静的settings定義、Cica fontのファイル列挙には重複がある。
これらの重複は現在の挙動には影響していないが、将来同じ値を変更するときに複数箇所を合わせて更新する必要がある。
また、CI workflowの名称が検証内容より狭く、READMEの章構成も主要用途ごとに整理されていない。
`cache.numtide.com` のbinary cache設定は現在のローカル検証でuntrusted substituterとして無視されており、設定を残してもbuild時間の改善を確認できない。

生成されるdotfilesとHome Managerの挙動を維持したまま、重複している定義を小さく整理し、設定の見通しを良くする。

## 要求事項

- 生成されるdotfilesとHome Managerの挙動を変えない。
- Bash/Zshで共通するaliasを一箇所で定義する。
- Bash/Zshで共通するGit prompt用環境変数設定を一箇所で定義する。
- Bash/Zsh固有のprompt、completion読み込み、history設定は各shell moduleに残す。
- Bash/Zsh関連moduleは `home/shell` 配下にまとめる。
- Claude Codeのwrapperと `~/.claude/settings.nix.json` の生成先は維持する。
- `~/.claude/settings.json` はHome Manager管理対象に含めない。
- `~/.codex/config.toml` はHome Manager管理対象に含めない。
- Cica fontのfont file一覧はCica package定義内のlistとして共通化する。
- Cica fontのversion、source URL、source hash、install先、Home Manager配置先を維持する。
- `treefmt-nix` のNix formatter packageは、現在のNixpkgsで推奨される `pkgs.nixfmt` を使用する。
- `cache.numtide.com` のbinary cache設定を削除する。
- CI workflow fileとworkflow名を、format/lintとHome Manager buildの両方を表す名前にする。
- READMEはsetupとGit関連設定で章を整理し、使っていない検証手順を削除する。
- READMEにflake input更新手順を記載する。
- 既存の `specs/features` は履歴として扱い、変更しない。

## 非対象

- 個人設定を汎用Home Manager moduleまたはflake optionへ変換すること。
- `home.username`、`home.homeDirectory`、Git authorなどの個人設定の配置変更。
- 生成されるshell promptやaliasの内容変更。
- Claude Code、Codex、Git、GPG、tmux、Neovim、Ghosttyの機能追加。
- `~/.claude/settings.json` や `~/.codex/config.toml` のNix管理化。
- Nix Flakes inputの更新。
- CI workflowの実行条件、job内容、runner、検証コマンドの変更。
- 過去specの編集。

## 機能要件

### Flake

- `formatter.aarch64-darwin` は引き続き `treefmt-nix` で定義する。
- `checks.aarch64-darwin.format` は引き続き `treefmt-nix` のformat checkを使用する。
- Nix formatterは `pkgs.nixfmt` を使用する。
- `nixConfig.extra-substituters` と `nixConfig.extra-trusted-public-keys` による `cache.numtide.com` 設定は削除する。
- `checks.aarch64-darwin.statix` と `checks.aarch64-darwin.deadnix` は維持する。
- `homeConfigurations.kakudo` は維持する。

### Shell

- Bash/Zsh moduleは `home/shell/default.nix` からimportする。
- Bash/Zsh共通aliasは共通helperから参照する。
- 共通aliasには既存の `ls = "lsd"`、`ll = "ls -alF"`、`la = "ls -A"` を含める。
- Git prompt用環境変数には既存の `GIT_PS1_SHOWDIRTYSTATE`、`GIT_PS1_SHOWSTASHSTATE`、`GIT_PS1_SHOWUNTRACKEDFILES`、`GIT_PS1_SHOWUPSTREAM` を含める。
- Bashは引き続き `~/.config/git/git-completion.sh` と `~/.config/git/git-prompt.sh` を読み込む。
- Zshは引き続き `~/.config/git/git-prompt.sh` を読み込む。
- Bash/Zshのprompt文字列は維持する。
- Bashのhistory設定は維持する。
- Zshの `dotDir`、`enableCompletion`、`setOptions` は維持する。

### Claude Code

- Claude Codeの静的settings attrsetは `home/agents/claude-code.nix` 内に維持する。
- settingsの値は既存の `env`、`attribution`、`effortLevel`、`language`、`theme`、`permissions.allow` を維持する。
- `claude` wrapperは引き続き実体のClaude Codeを `--settings "$HOME/.claude/settings.nix.json"` 付きで実行する。
- `~/.claude/settings.nix.json` は引き続きNix管理のJSONとして生成する。
- `~/.claude/settings.json` は生成、置換、削除しない。
- `home/agents/PROMPT.md` をClaude CodeとCodexの共通プロンプトとして維持する。

### Cica font

- Cica fontのfont file名は `pkgs/cica.nix` 内のlistで定義する。
- package install phaseは共通listからtruetype fontを `$out/share/fonts/truetype` に配置する。
- Cica packageはfont file listを `passthru` で公開する。
- Home ManagerはCica packageのfont file listから `~/Library/Fonts` への配置を定義する。
- `LICENSE.txt` と `COPYRIGHT.txt` のdoc配置は維持する。

### CI

- Workflow fileは `.github/workflows/checks.yaml` とする。
- Workflow名は `Checks` とする。
- `pull_request` と `main` branchへの `push` で実行する設定は維持する。
- `flake-check` jobは `nix flake check --show-trace` を実行する。
- `home-manager-build` jobはHome Manager activation packageをbuildする。

### Documentation

- READMEのsetup手順は `Setup` 配下にまとめる。
- READMEのGit local configとGPG signing手順は `Git` 配下にまとめる。
- READMEの `Setup` 配下に `nix flake update` と `home-manager switch --flake .#kakudo` による更新手順を記載する。
- READMEから現在使っていない `Verify` 章を削除する。
- Bootstrap、first apply、daily apply、GPG signingの手順自体は維持する。

## 非機能要件

- 秘密情報、認証情報、token、session、cache、log、local stateをGit管理対象やNix storeに含めない。
- Nix管理の静的設定とツール本体が更新するmutable fileの分離を維持する。
- リファクタリングによってHome Manager activation時の管理対象fileを増やさない。
- リファクタリングによって外部サービスへの書き込みやユーザー環境へのactivationを行わない。
- 変更は重複削減と警告解消に必要な範囲に限定する。

## 検証

- ローカルで `nix flake check --show-trace` が成功すること。
- ローカルで `nix build --no-link --print-out-paths .#homeConfigurations.kakudo.activationPackage` が成功すること。
- 生成されるHome Manager filesに `~/.claude/settings.nix.json` が含まれること。
- 生成されるHome Manager filesに `~/.claude/settings.json` が含まれないこと。
- 生成されるHome Manager filesに `~/.codex/config.toml` が含まれないこと。
- Cica fontsの `~/Library/Fonts/*.ttf` 配置が維持されること。
