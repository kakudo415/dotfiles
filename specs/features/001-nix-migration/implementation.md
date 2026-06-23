# Nix Migration Implementation

## 方針

実装は、共通設定をHome Manager moduleへ寄せ、PC固有設定と秘匿情報を`$XDG_CONFIG_HOME/local/`配下から実行時に読む形で進める。

Home Manager moduleがあるツールは、`home.file`や`xdg.configFile`で設定ファイルを丸ごと置かず、可能な限り`programs.*` moduleの設定項目を使う。Home Manager公式moduleがないJSON設定は、自前moduleのactivation scriptで共通JSONとlocal JSONをmergeする。

## Phase 0: 事前確認

### 対象環境

- macOS
- `aarch64-darwin`
- 公式Nix installer
- Home Manager単体
- flake output: `homeConfigurations."kakudo"`

### 既存ファイル確認

Home Manager適用前に、対象PC上で次のファイルの存在と内容を確認する。

```sh
ls -la ~/.bashrc ~/.zshrc ~/.config/git/config ~/.config/git/ignore
ls -la ~/.config/tmux/tmux.conf ~/.config/nvim/init.vim
ls -la ~/.config/ghostty/config ~/.config/gdb/gdbinit ~/.claude/settings.json
```

衝突する既存ファイルは、Home Manager初回適用前に退避する。退避先は例として`~/dotfiles-backup/<date>/`を使う。

### local layer確認

local layerの標準パスは次の通り。

```sh
${XDG_CONFIG_HOME:-$HOME/.config}/local
```

必要に応じて、各PCで次のファイルをGit管理外に作成する。

```text
$XDG_CONFIG_HOME/local/
├── shell
│   ├── bashrc
│   └── zshrc
├── git
│   ├── config
│   └── ignore
└── claude
    └── settings.json
```

local layerの中身はNix評価時に読まない。shell、Git、Neovim、tmuxなどは実行時include/sourceで読む。JSONはHome Manager activation時に`jq`でmergeする。

local layerの標準設定ファイルが存在しない場合は、Home Manager activation時に空ファイルを作成する。JSONファイルは空文字ではなく`{}`を入れる。

## Phase 1: Nix導入

公式Nix installerでNixを導入する。

導入後、Flakesと`nix-command`を有効化する。設定場所は公式Nixの導入形態に合わせるが、最終的に次のexperimental featuresが有効であることを確認する。

```conf
experimental-features = nix-command flakes
```

確認:

```sh
nix --version
nix flake --help
```

## Phase 2: flakeの入口

### 追加ファイル

```text
flake.nix
flake.lock
home/default.nix
```

### flake方針

- inputは`nixpkgs`と`home-manager`から始める。
- `home-manager.inputs.nixpkgs.follows = "nixpkgs"`を設定する。
- systemは`aarch64-darwin`に固定する。
- outputは`homeConfigurations."kakudo"`の1つにする。

### home/default.nix方針

- 共通moduleをimportする。
- `home.stateVersion`を明示する。
- `programs.home-manager.enable = true`を設定する。
- GUIアプリとフォントは第一段階では管理しない。

初回追加後の確認:

```sh
nix flake check
home-manager build --flake .#kakudo
```

## Phase 3: module構成

### 追加ディレクトリ

```text
home/
├── default.nix
└── modules
    ├── shell.nix
    ├── git.nix
    ├── tmux.nix
    ├── neovim.nix
    ├── terminal.nix
    ├── gdb.nix
    ├── claude.nix
    ├── json-merge.nix
    └── tools.nix
```

### module責務

- `shell.nix`: bash、zsh、shell共通設定、local shell include
- `git.nix`: Git共通設定、global ignore、local git include
- `tmux.nix`: tmux設定
- `neovim.nix`: Neovim設定
- `terminal.nix`: Ghostty設定
- `gdb.nix`: GDB設定
- `claude.nix`: Claude共通JSON定義とmerge設定
- `json-merge.nix`: activation-time JSON merge helper
- `tools.nix`: CLI package管理

## Phase 4: local layer初期化

Home Manager activation時にlocal layerのディレクトリと標準設定ファイルを作る。

作成するディレクトリ:

```text
${XDG_CONFIG_HOME:-$HOME/.config}/local/shell
${XDG_CONFIG_HOME:-$HOME/.config}/local/git
${XDG_CONFIG_HOME:-$HOME/.config}/local/claude
```

作成するファイル:

```text
${XDG_CONFIG_HOME:-$HOME/.config}/local/shell/bashrc
${XDG_CONFIG_HOME:-$HOME/.config}/local/shell/zshrc
${XDG_CONFIG_HOME:-$HOME/.config}/local/git/config
${XDG_CONFIG_HOME:-$HOME/.config}/local/git/ignore
${XDG_CONFIG_HOME:-$HOME/.config}/local/claude/settings.json
```

ファイルが既に存在する場合は変更しない。

初期内容:

- shell、Gitのlocalファイルは空ファイルにする。
- JSONファイルは`{}`にする。

この初期化はGit管理外のローカルファイルだけを対象にする。公開リポジトリのファイルやNix storeにはlocal layerの内容を入れない。

## Phase 5: shell移行

### bash

移行先:

```nix
programs.bash.initExtra
```

移植内容:

- interactive shell guard
- `checkwinsize`
- `histappend`
- git completion/prompt
- prompt
- history設定
- `lsd` alias
- `ll` / `la`
- local bashrc source

local bashrc:

```sh
local_bashrc="${XDG_CONFIG_HOME:-$HOME/.config}/local/shell/bashrc"
[ -r "$local_bashrc" ] && . "$local_bashrc"
```

### zsh

移行先:

```nix
programs.zsh.initContent
```

移植内容:

- `PROMPT_SUBST`
- git prompt
- prompt
- `lsd` alias
- `ll` / `la`
- 既存の`~/.zshrc.local`互換
- local zshrc source

local zshrc:

```sh
[ -f ~/.zshrc.local ] && . ~/.zshrc.local

local_zshrc="${XDG_CONFIG_HOME:-$HOME/.config}/local/shell/zshrc"
[ -r "$local_zshrc" ] && . "$local_zshrc"
```

### git prompt/completion

`~/.config/git/git-prompt.sh`や`git-completion.sh`を前提にせず、Nixの`pkgs.git`由来のファイルを参照する。

## Phase 6: Git移行

移行先:

```nix
programs.git
programs.git.ignores
```

共通設定:

- `user.name = "KAKUDO Kentaro"`
- `user.email = "31888089+kakudo415@users.noreply.github.com"`
- `core.editor = "nvim"`
- global ignore: `.DS_Store`

local設定:

```gitconfig
[include]
    path = ~/.config/local/git/config
```

`XDG_CONFIG_HOME`を既定値以外にする場合は、Home Manager側で生成するinclude pathも合わせる。Git config内ではshellの`${XDG_CONFIG_HOME:-...}`展開を期待しない。実装では`config.xdg.configHome`相当の値からlocal Git config pathを組み立てる。

local Git設定に置くもの:

- 職場メール
- `user.signingkey`
- `commit.gpgsign`
- `gpg.program`
- credential helper
- 社内Git hostの`url.*.insteadOf`
- 必要に応じた`includeIf "gitdir:..."`

## Phase 7: ツール設定移行

### tmux

移行先:

```nix
programs.tmux.extraConfig
```

既存の`dot_config/tmux/tmux.conf`を移植する。local tmux設定が必要になった場合は、末尾で次を読む。

```tmux
if-shell '[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/local/tmux/tmux.conf" ]' 'source-file "${XDG_CONFIG_HOME:-$HOME/.config}/local/tmux/tmux.conf"'
```

tmux内での環境変数展開が期待通りにならない場合は、Home Manager側で絶対パスを生成する。

### Neovim

移行先:

```nix
programs.neovim.extraConfig
```

既存の`dot_config/nvim/init.vim`を移植する。local vimscriptが必要な場合は、末尾で次を読む。

```vim
let s:local_init = expand('$XDG_CONFIG_HOME') . '/local/nvim/init.vim'
if empty(expand('$XDG_CONFIG_HOME'))
  let s:local_init = expand('~/.config/local/nvim/init.vim')
endif
if filereadable(s:local_init)
  execute 'source' fnameescape(s:local_init)
endif
```

プラグイン管理は第一段階では扱わない。

### Ghostty

移行先:

```nix
programs.ghostty.settings
```

移植内容:

- `font-family = "Cica"`
- `font-size = 16`
- `background-opacity = 0.85`
- `background-blur-radius = 15`

GhosttyはGUIアプリ本体のinstall対象外。設定だけHome Managerで管理する。

### GDB

移行先:

```nix
programs.gdb.initExtra
```

移植内容:

```gdb
set disassembly-flavor intel
```

### Claude

Home Manager公式moduleがないため、自前moduleで扱う。

移行先:

```text
home/modules/claude.nix
home/modules/json-merge.nix
```

共通JSON:

```json
{
  "env": {
    "EDITOR": "nvim",
    "DISABLE_ERROR_REPORTING": 1,
    "DISABLE_TELEMETRY": 1
  },
  "includeCoAuthoredBy": false
}
```

local JSON:

```text
${XDG_CONFIG_HOME:-$HOME/.config}/local/claude/settings.json
```

出力先:

```text
~/.claude/settings.json
```

merge rule:

- localがcommonを上書きする。
- 配列はlocalで上書きする。
- local JSONが存在しない場合は`{}`を入れたファイルを作成してからmergeする。
- local JSONをNix評価時に読まない。
- merge結果をNix storeへ入れない。

## Phase 8: package管理

初期package候補:

- `git`
- `tmux`
- `neovim`
- `gdb`
- `lsd`
- `jq`
- `gnupg`
- `rust-analyzer`

方針:

- Home Manager moduleの`programs.*.enable`で導入できるものはmodule側を優先する。
- moduleで扱いづらいCLI toolは`home.packages`へ入れる。
- GUIアプリとフォントは第一段階では管理しない。

## Phase 9: 検証

### flake検証

```sh
nix flake check
```

### build検証

```sh
home-manager build --flake .#kakudo
```

確認対象:

- buildが成功する。
- `result/home-files`以下に主要ファイルが生成される。
- `.bashrc`と`.zshrc`にlocal sourceが含まれる。
- Git configにlocal includeが含まれる。
- Claude settings merge用activation scriptが生成される。
- local layerの標準設定ファイルを作るactivation scriptが生成される。

### dry-run相当の確認

Home Managerが衝突を報告した場合は、既存ファイルを退避してから再実行する。衝突ファイルを上書きするためだけに強制削除しない。

## Phase 10: 実機適用

まず片方のPCで適用する。

```sh
home-manager switch --flake .#kakudo
```

確認:

- shell起動時にエラーが出ない。
- promptが再現されている。
- `ls` / `ll` / `la` aliasが期待通り。
- `git config --global --list --show-origin`で共通設定とlocal includeが確認できる。
- `tmux`設定が反映されている。
- `nvim`設定が反映されている。
- Ghostty設定が反映されている。
- `gdb`でdisassembly flavorがintelになっている。
- local layerの標準設定ファイルが存在する。
- `~/.claude/settings.json`が生成され、local JSONがある場合は上書きmergeされている。

問題がなければもう一方のPCでも同じflake outputを適用する。

## Phase 11: chezmoi停止

Home Manager適用後にchezmoi管理を停止する。

移行完了後に削除するもの:

- `.chezmoi.toml.tmpl`
- `.chezmoiignore`
- chezmoi形式の元ファイル

READMEを更新する。

記載する内容:

- Nix導入手順
- `home-manager switch --flake .#kakudo`
- local layerの作成方法
- rollback手順
- chezmoiから移行済みであること

## Rollback

Home Managerの世代を確認する。

```sh
home-manager generations
```

必要に応じて、戻したい世代の`activate`を実行する。

```sh
/nix/store/<generation-path>/activate
```

Home Manager適用前に退避したファイルが必要な場合は、退避先から手動で戻す。
