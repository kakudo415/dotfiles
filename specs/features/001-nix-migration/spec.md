# Nix Migration

## 目的

現在chezmoiで管理しているdotfilesを、Nixを入口にした宣言的な管理へ移行する。

最初の到達点は、現在このリポジトリにあるdotfilesをHome Managerで再現し、macOSの複数PCへ同じ公開リポジトリから適用できる状態にすること。

## 背景

現在のchezmoi管理対象は、ユーザーのホーム配下に置くdotfilesで構成されている。OSレベルの設定、macOS defaults、Homebrew、LaunchDaemon、Nix daemon、`/etc`配下の設定は含まれていない。

対象PCはmacOSで、いずれも`aarch64-darwin`を想定する。

技術選定の詳細は、各決定事項に対応するADRに記録する。

### 現状のchezmoi管理対象

| 現在のファイル | 移行先候補 | 備考 |
| --- | --- | --- |
| `.chezmoi.toml.tmpl` | 廃止 | GPG key ID入力はGit local layerまたはsecret管理へ移す。 |
| `.chezmoiignore` | 廃止 | Nix移行後は不要。 |
| `dot_bashrc` | `programs.bash.initExtra`または`home.file.".bashrc".text` | git completion/promptはNixの`git`パッケージ由来のファイルを参照する。 |
| `dot_zshrc` | `programs.zsh.initContent`または`home.file.".zshrc".text` | 既存の`~/.zshrc.local`読み込みは維持する。 |
| `dot_config/git/config.tmpl` | `programs.git` | 共通Git設定を移植する。GPG signing keyや職場Git設定は公開設定から分離する。 |
| `dot_config/git/ignore` | `programs.git.ignores`または`xdg.configFile."git/ignore"` | `.DS_Store`を維持する。 |
| `dot_config/tmux/tmux.conf` | `programs.tmux.extraConfig` | 既存設定をそのまま移植する。 |
| `dot_config/nvim/init.vim` | `programs.neovim.extraConfig`または`xdg.configFile."nvim/init.vim"` | まずは挙動維持を優先し、プラグイン管理は別タスクにする。 |
| `dot_config/ghostty/config` | `xdg.configFile."ghostty/config"` | fontやopacity設定を維持する。 |
| `dot_config/gdb/gdbinit` | `xdg.configFile."gdb/gdbinit"` | そのまま配置する。 |
| `dot_claude/settings.json` | activation時に共通JSONとlocal JSONをmerge | telemetry無効化等を維持する。 |

## 要求事項

### 対象範囲

- 現在chezmoiで配置している対象ファイルをHome Managerで配置または生成できること。
- 複数PCを同じリポジトリから管理できること。
- 対象PCはmacOSのみとし、systemは`aarch64-darwin`のみを対象にすること。[ADR](./adr/home-manager-and-flakes.md)
- GUIアプリとフォントは第一段階の管理対象外にすること。
- 移行直後は挙動維持を優先し、Neovimプラグイン管理やmacOS defaults管理などの拡張は後続フェーズに回すこと。

### NixとHome Manager

- Nix installerは公式Nix installerを使うこと。[ADR](./adr/nix-installer.md)
- 第一段階ではHome Manager単体で管理し、nix-darwinは導入しないこと。[ADR](./adr/home-manager-and-flakes.md)
- Flakesを採用し、`flake.nix`と`flake.lock`でHome Manager構成を管理すること。[ADR](./adr/home-manager-and-flakes.md)
- `flake.lock`はコミットし、複数PCで同じ入力バージョンを使うこと。
- Nix式はmodule単位に分割し、1ファイルに全設定を詰め込まないこと。

### Local Layerと秘匿情報

- 公開リポジトリでは共通設定のみを管理し、PCごとの設定や秘匿情報はGit管理外のlocal layerで扱うこと。[ADR](./adr/local-layer.md)
- 職場PC専用の情報は公開リポジトリに含めないこと。
- 職場PC専用の設定ファイルは、公開flakeのNix評価時に読み込まないこと。
- GPG signing key、職場Gitメール、職場用credential/helper、職場固有PATH、社内ツール設定などはローカル完結のファイルまたはsecret管理から参照できること。
- local-onlyファイルのパスは`$XDG_CONFIG_HOME/local/`にすること。`XDG_CONFIG_HOME`が未設定の場合は`~/.config/local/`を使うこと。[ADR](./adr/local-layer.md)

### JSON設定

- JSON設定ファイルを持つツールは、共通JSONとlocal JSONをmergeして最終設定を生成できること。[ADR](./adr/local-layer.md)
- JSON mergeは、まずlocal側がcommon側を上書きする方針にすること。
- JSON配列は、まずlocal側で上書きする方針にすること。

### Shellとツール設定

- 既存の`~/.zshrc.local`読み込み互換は維持すること。
- NixでinstallできるCLI toolやアプリ依存は、可能な限りHome Managerの`home.packages`または各`programs.*` moduleで管理すること。

### 運用と検証

- 移行後も`home-manager generations`とrollbackで前の世代へ戻れること。
- CIまたはローカル検証で`nix flake check`相当を実行できる構成にすること。

## 構成方針

共通設定とlocal設定の2-layer構成を採用する。

```text
Layer 1: public common layer
  - このリポジトリで管理する
  - Home Managerでbuild/checkできる
  - 共通dotfilesとNixでinstallできるpackageを定義する
  - local layerへの参照またはactivation-time mergeだけを持つ

Layer 2: local layer
  - Git管理外
  - 各PCの`$XDG_CONFIG_HOME/local/`に置く
  - 秘匿情報、職場情報、PC固有PATH、local JSON差分を置く
  - Nix評価時には読まれない
```

第一段階では、個人PC/職場PC profileやPC固有host moduleは作らない。対象がmacOSかつ`aarch64-darwin`に揃っているため、公開flake outputは1つにする。

将来、公開可能な非秘密差分が必要になった場合のみ、host moduleやprofile moduleを追加する。例: `x86_64-darwin`が増えた、ユーザー名やhome directoryが異なる、GUIツールの有無をPCごとに変えたい、など。

## Local Layer

推奨ディレクトリ:

```text
$XDG_CONFIG_HOME/local/
├── shell
│   ├── bashrc
│   └── zshrc
├── git
│   ├── config
│   └── ignore
├── claude
│   └── settings.json
└── README.local.md
```

`XDG_CONFIG_HOME`が未設定の場合は`~/.config/local/`を使う。

Git/GPGの分離:

- 共通設定: `user.name`、公開用GitHub noreplyメール、`core.editor`、global ignore
- ローカル設定: 職場メール、`user.signingkey`、`commit.gpgsign`、`gpg.program`、credential helper、社内Git hostの`url.*.insteadOf`
- 職場リポジトリだけで設定を切り替える場合は、ローカルGit設定内で`includeIf "gitdir:..."`を使う。

JSON設定ファイルを持つツールは、Home Managerのactivation時に共通JSONとlocal JSONをmergeして最終ファイルを生成する。

基本方針:

- 共通JSONはNix store上に生成してよい。
- local JSONは`$XDG_CONFIG_HOME/local/<tool>/<file>.json`に置く。
- Nix評価時にlocal JSONを読まない。
- `home.file`や`xdg.configFile`で最終出力先を直接管理しない。Home Managerのactivation scriptで`jq`を使って最終ファイルを生成する。
- local JSONが存在しない場合は、共通JSONだけで最終ファイルを生成する。
- merge ruleは、まずlocal側がcommon側を上書きする方式にする。配列もlocal側で上書きする。
- merge結果はホームディレクトリ配下に作られ、Nix storeには入れない。

例:

```sh
jq -s '.[0] * .[1]' \
  "$COMMON_JSON_IN_NIX_STORE" \
  "${XDG_CONFIG_HOME:-$HOME/.config}/local/claude/settings.json" \
  > "$HOME/.claude/settings.json"
```

## 用意・実装するもの

### リポジトリ構成案

```text
.
├── flake.nix
├── flake.lock
├── home
│   ├── default.nix
│   └── modules
│       ├── shell.nix
│       ├── git.nix
│       ├── tmux.nix
│       ├── neovim.nix
│       ├── terminal.nix
│       ├── claude.nix
│       ├── json-merge.nix
│       └── tools.nix
├── specs
│   └── features
│       └── 001-nix-migration
│           ├── spec.md
│           └── adr
│               ├── nix-installer.md
│               ├── home-manager-and-flakes.md
│               └── local-layer.md
└── README.md
```

### flake outputs案

```nix
{
  homeConfigurations."kakudo" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    modules = [
      ./home
    ];
  };
}
```

想定コマンド:

```sh
home-manager switch --flake .#kakudo
```

## 実装手順

1. 事前バックアップ
   - 現在の`~/.bashrc`、`~/.zshrc`、`~/.config/git/config`、`~/.config/tmux/tmux.conf`などを確認する。
   - Home Manager初回適用時に衝突する既存ファイルは退避する。

2. Nix/Home Managerの入口を作る
   - 公式Nix installerでmacOSへNixを導入する。
   - `flake.nix`を追加する。
   - inputは`nixpkgs`と`home-manager`から始める。
   - `home-manager.inputs.nixpkgs.follows = "nixpkgs"`を設定する。
   - `flake.lock`を生成してコミット対象にする。

3. 共通Home Manager moduleを作る
   - `home/default.nix`で共通moduleをimportする。
   - `home.stateVersion`を明示する。値は初回導入時のHome Manager releaseに固定し、安易に更新しない。
   - `programs.home-manager.enable = true`を設定する。

4. shell設定を移行する
   - bash/zshの既存プロンプト、履歴、aliasを移植する。
   - `git-prompt.sh`と`git-completion.sh`は`pkgs.git`由来のパスを使う。
   - `lsd`は`home.packages`に追加する。
   - `~/.zshrc.local`互換に加え、`${XDG_CONFIG_HOME:-$HOME/.config}/local/shell/*`を読む。

5. Git設定を移行する
   - `programs.git.enable = true`を設定する。
   - 共通の`user.name`、公開メール、editorを移す。
   - GPG signing keyは公開設定から外し、`${XDG_CONFIG_HOME:-$HOME/.config}/local/git/config`で設定する。
   - global ignoreを移す。

6. ツール設定を移行する
   - tmuxは`programs.tmux.extraConfig`へ移す。
   - Neovimはまず既存`init.vim`相当を再現する。
   - Ghostty、gdbは`xdg.configFile`または`home.file`で配置する。
   - ClaudeなどJSON設定は、共通JSONとlocal JSONをactivation時にmergeして配置する。

7. package管理を追加する
   - Nixでinstallできるものは可能な限り`home.packages`またはHome Managerの`programs.*` moduleで管理する。
   - 初期候補は`git`、`tmux`、`neovim`、`gdb`、`lsd`、`jq`、`gnupg`、`rust-analyzer`。
   - GUIアプリやフォントは第一段階では管理しない。

8. 検証する
   - `nix flake check`
   - `home-manager build --flake .#kakudo`
   - 生成結果の主要ファイルを`result/home-files`以下で確認する。
   - 実機適用は片方のPCで`home-manager switch --flake .#kakudo`を実行し、問題がなければもう一方へ進める。

9. chezmoiから切り替える
   - Home Manager適用後にchezmoi管理を停止する。
   - `.chezmoi.toml.tmpl`と`.chezmoiignore`は移行完了後に削除する。
   - READMEをNix/Home Managerの導入手順に更新する。

10. 後続フェーズを判断する
    - macOS defaults、フォント、Homebrew cask、Touch ID sudo、Dock設定などを管理したくなった場合にnix-darwin導入を再検討する。
    - secretをGitで暗号化管理したくなった場合はsops-nixまたはagenixを導入する。
    - private Nix moduleが必要になった場合は、公開リポジトリとは別にprivate flakeまたはprivate repositoryを作る。

## 完了条件

- `home-manager build --flake .#kakudo`が成功する。
- 現在chezmoiで管理している対象dotfilesの内容が、Home Manager管理下で再現されている。
- 職場PC専用情報を含むファイルがGit管理対象に含まれていない。
- local JSONがある場合、共通JSONとmergeされた最終JSONが生成される。
- READMEに新しい導入・適用・rollback手順が記載されている。
