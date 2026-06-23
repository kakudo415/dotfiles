# Nix Migration

## 目的

現在chezmoiで管理しているdotfilesを、Nixを入口にした宣言的な管理へ移行する。

最初の到達点は、現在このリポジトリにあるdotfilesをHome Managerで再現し、macOSの複数PCへ同じ公開リポジトリから適用できる状態にすること。

## 背景

現在のchezmoi管理対象は、ユーザーのホーム配下に置くdotfilesで構成されている。OSレベルの設定、macOS defaults、Homebrew、LaunchDaemon、Nix daemon、`/etc`配下の設定は含まれていない。

対象PCはmacOSで、いずれも`aarch64-darwin`を想定する。

技術選定の詳細は、各決定事項に対応するADRに記録する。

### 現状のchezmoi管理対象

| 現在のファイル | 移行先 | 備考 |
| --- | --- | --- |
| `.chezmoi.toml.tmpl` | 廃止 | GPG key ID入力はGit local layerまたはsecret管理へ移す。 |
| `.chezmoiignore` | 廃止 | Nix移行後は不要。 |
| `dot_bashrc` | `programs.bash.initExtra` | git completion/promptはNixの`git`パッケージ由来のファイルを参照する。末尾でlocal bashrcをsourceする。 |
| `dot_zshrc` | `programs.zsh.initContent` | 既存の`~/.zshrc.local`読み込みを維持し、末尾でlocal zshrcをsourceする。 |
| `dot_config/git/config.tmpl` | `programs.git` | 共通Git設定を移植する。GPG signing keyや職場Git設定はGit includeでlocal layerへ分離する。 |
| `dot_config/git/ignore` | `programs.git.ignores` | `.DS_Store`を維持する。 |
| `dot_config/tmux/tmux.conf` | `programs.tmux.extraConfig` | 既存設定をそのまま移植する。 |
| `dot_config/nvim/init.vim` | `programs.neovim.extraConfig` | まずは挙動維持を優先し、プラグイン管理は別タスクにする。local vimscriptが必要な場合は末尾でsourceする。 |
| `dot_config/ghostty/config` | `programs.ghostty` | `enable`と`settings`を使い、fontやopacity設定を維持する。 |
| `dot_config/gdb/gdbinit` | `home/modules/gdb.nix` | Home Manager公式moduleがないため、自前moduleで`~/.config/gdb/gdbinit`を生成する。 |
| `dot_claude/settings.json` | `home/modules/claude.nix` + `home/modules/json-merge.nix` | Home Manager公式moduleがないため、自前moduleのactivation scriptで共通JSONとlocal JSONをmergeする。 |

## 要求事項

### 対象範囲

- 現在chezmoiで配置している対象ファイルをHome Managerで配置または生成できること。
- 複数PCを同じリポジトリから管理できること。
- 対象PCはmacOSのみとし、systemは`aarch64-darwin`のみを対象にすること。[ADR](./adr/home-manager-and-flakes.md)
- Home Manager moduleで管理できるGUIアプリは、アプリ本体もHome Managerで管理すること。
- フォントは第一段階の管理対象外にすること。
- 移行直後は挙動維持を優先し、Neovimプラグイン管理やmacOS defaults管理などの拡張は今回の実装対象外にすること。

### NixとHome Manager

- Nix installerは公式Nix installerを使うこと。[ADR](./adr/nix-installer.md)
- 第一段階ではHome Manager単体で管理し、nix-darwinは導入しないこと。[ADR](./adr/home-manager-and-flakes.md)
- Flakesを採用し、`flake.nix`と`flake.lock`でHome Manager構成を管理すること。[ADR](./adr/home-manager-and-flakes.md)
- `flake.lock`はコミットし、複数PCで同じ入力バージョンを使うこと。
- 初回適用と通常適用の入口は、flake内の`apps.aarch64-darwin.apply`からHome Manager activation packageを実行する`nix run .#apply`に統一すること。[ADR](./adr/home-manager-and-flakes.md)
- `home.stateVersion`は初回導入時のHome Manager互換性基準として`26.05`に固定し、通常のinput更新では変更しないこと。[ADR](./adr/home-manager-and-flakes.md)
- Nix式はmodule単位に分割し、1ファイルに全設定を詰め込まないこと。

### Local Layerと秘匿情報

- 公開リポジトリでは共通設定のみを管理し、PCごとの設定や秘匿情報はGit管理外のlocal layerで扱うこと。[ADR](./adr/local-layer.md)
- 職場PC専用の情報は公開リポジトリに含めないこと。
- 職場PC専用の設定ファイルは、公開flakeのNix評価時に読み込まないこと。
- GPG signing key、職場Gitメール、職場用credential/helper、職場固有PATH、社内ツール設定などはローカル完結のファイルまたはsecret管理から参照できること。
- local-onlyファイルのパスは`$XDG_CONFIG_HOME/local/`にすること。`XDG_CONFIG_HOME`が未設定の場合は`~/.config/local/`を使うこと。[ADR](./adr/local-layer.md)
- local layerの標準設定ファイルが存在しない場合は、shell/Git向けには空ファイル、JSON向けには`{}`を入れたファイルを作成すること。
- Home Manager activationでは、local layer初期化をJSON mergeより先に実行すること。

### JSON設定

- JSON設定ファイルを持つツールは、共通JSONとlocal JSONをmergeして最終設定を生成できること。[ADR](./adr/local-layer.md)
- JSON mergeは、まずlocal側がcommon側を上書きする方針にすること。
- JSON配列は、まずlocal側で上書きする方針にすること。

### Shellとツール設定

- 既存の`~/.zshrc.local`読み込み互換は維持すること。
- Home Manager moduleがあるツールは、`home.file`や`xdg.configFile`による丸ごと配置ではなく、可能な限り各`programs.*` moduleの設定項目を使うこと。
- NixでinstallできるCLI toolやアプリ依存は、可能な限りHome Managerの`home.packages`または各`programs.*` moduleで管理すること。
- Ghosttyは`programs.ghostty.enable = true`でアプリ本体も管理し、`aarch64-darwin`で既定packageがbuildできることを検証すること。利用不可の場合は設定だけ管理するfallbackを入れず、代替方針をADRで決めること。

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
│   └── config
├── claude
│   └── settings.json
└── README.local.md
```

`XDG_CONFIG_HOME`が未設定の場合は`~/.config/local/`を使う。

local layerの標準設定ファイルが存在しない場合は、Home Manager activation時に作成する。shell/Git向けは空ファイル、JSON向けは`{}`を入れたファイルにする。

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
- merge ruleは、まずlocal側がcommon側を上書きする方式にする。配列もlocal側で上書きする。
- local JSONが存在しない場合は、空JSON objectのファイルを作成してからmergeする。
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
│           ├── implementation.md
│           └── adr
│               ├── nix-installer.md
│               ├── home-manager-and-flakes.md
│               └── local-layer.md
└── README.md
```

### flake outputs案

```nix
outputs = { self, nixpkgs, home-manager, ... }: {
  homeConfigurations."kakudo" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    modules = [
      ./home
    ];
  };

  apps.aarch64-darwin.apply = {
    type = "app";
    program = "${self.homeConfigurations.kakudo.activationPackage}/activate";
  };
}
```

想定コマンド:

```sh
nix run .#apply
```

Home Manager適用後も`nix run .#apply`を標準の適用コマンドにする。`home-manager switch --flake .#kakudo`は補助的なコマンドとして使える。

## 実装手順

詳細な実装手順は[implementation.md](./implementation.md)に記録する。

大まかな順序:

1. 既存dotfilesと衝突ファイルを確認する。
2. 公式Nix installerでNixを導入し、Flakesを有効化する。
3. `flake.nix`、`flake.lock`、`home/default.nix`を追加する。
4. Home Manager moduleを分割して、chezmoi管理対象を移植する。
5. local layer includeとJSON mergeを実装する。
6. `nix flake check`と`nix build .#homeConfigurations.kakudo.activationPackage`で検証する。
7. 実機で`nix run .#apply`を適用し、chezmoi管理を停止する。

## 完了条件

- `nix build .#homeConfigurations.kakudo.activationPackage`が成功する。
- 現在chezmoiで管理している対象dotfilesの内容が、Home Manager管理下で再現されている。
- 職場PC専用情報を含むファイルがGit管理対象に含まれていない。
- local JSONがある場合、共通JSONとmergeされた最終JSONが生成される。
- READMEに新しい導入・適用・rollback手順が記載されている。
