# Nix Migration

## 背景

このリポジトリは現在、chezmoiのソース形式でdotfilesを管理している。
Nix、Home Manager、Nix Flakesを使う構成へ移行し、chezmoiで管理しているdotfilesをNix管理へ置き換える。

現在のchezmoi管理対象は以下の通り。

| chezmoi source | 展開先 | 備考 |
| --- | --- | --- |
| `dot_zshrc` | `~/.zshrc` | Zshのprompt、alias |
| `dot_bashrc` | `~/.bashrc` | Bashのprompt、履歴設定、alias |
| `dot_config/git/config.tmpl` | `~/.config/git/config` | Git user設定、editor、任意のGPG署名設定 |
| `dot_config/git/ignore` | `~/.config/git/ignore` | Git ignore設定 |
| `dot_config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | tmux設定 |
| `dot_config/nvim/init.vim` | `~/.config/nvim/init.vim` | Neovim設定 |
| `dot_config/gdb/gdbinit` | `~/.config/gdb/gdbinit` | GDB設定 |
| `dot_config/ghostty/config` | `~/.config/ghostty/config` | Ghostty設定 |
| `dot_config/sura/config.json` | `~/.config/sura/config.json` | Sura設定 |
| `dot_claude/settings.json` | `~/.claude/settings.json` | Claude設定 |
| `.chezmoi.toml.tmpl` | chezmoi設定 | GPG key IDの入力に使用 |
| `.chezmoiignore` | chezmoi除外 | README/LICENSEを除外 |

## 要求事項

- 現在chezmoiで管理しているdotfilesを、Nix FlakesとHome Managerを使うNix管理へ移行する。
- 移行後のHome Manager構成は、`aarch64-darwin` platform向けの `homeConfigurations.kakudo` として提供する。
- Nixpkgsは `nixpkgs-unstable` を使用し、Nix Flakes inputsは `flake.lock` で固定する。
- Home Managerは最新stable releaseを使用する。
- 移行後はHome Managerのactivationによって対象dotfilesと対象ソフトウェアが用意される。
- 既存dotfilesの挙動は、移行対象外に定めるものを除いて維持する。
- 移行後はchezmoi関連ファイルをリポジトリから削除する。
- 次の項目は移行対象に含めない。
  - GPG署名設定。署名設定のないGit設定へ移行する。
  - Sura設定
  - Rust関連設定
  - Zshのローカル拡張設定
  - chezmoi関連

## 機能要件

### Nix Flakes

- リポジトリルートに `flake.nix` と `flake.lock` を配置する。
- `flake.nix` は `nixpkgs` と `home-manager` をNix Flakes inputsとして定義する。
- `nixpkgs.url` は `github:NixOS/nixpkgs/nixpkgs-unstable` とする。
- `home-manager.url` は `github:nix-community/home-manager/release-26.05` とする。
- `home-manager.inputs.nixpkgs.follows = "nixpkgs"` を設定する。
- `flake.nix` は `homeConfigurations.kakudo` を定義する。
- `homeConfigurations.kakudo` は `aarch64-darwin` のNixpkgs package setを使用する。
- `nix flake check` でHome Manager構成の評価確認ができるようにする。

### Home Manager

- `home.username` は `kakudo` とする。
- `home.homeDirectory` は `/Users/kakudo` とする。
- `home.stateVersion` は `26.05` とする。
- `programs.home-manager.enable = true` を設定する。
- 標準moduleで表現できる設定は、可能な限りHome Managerのmoduleで管理する。
- 標準moduleで表現しづらい設定は `home.file` または `xdg.configFile` で管理する。

### Packages

- Home Managerで次のソフトウェアを用意する。
  - `git`
  - `zsh`
  - `bash`
  - `tmux`
  - `neovim`
  - `gdb`
  - `ghostty`
  - `lsd`
  - Claude関連ツール
- Cica fontはHome Managerで用意する対象に含めない。

### Shell

- Zshのprompt、Git branch表示、aliasを維持する。
- Bashのinteractive判定、prompt、Git branch表示、履歴設定、aliasを維持する。
- `lsd` が利用可能な場合に `ls` aliasを切り替える挙動を維持する。
- `~/.cargo/env` の読み込みは移行しない。
- `~/.zshrc.local` の読み込みは移行しない。
- 既存設定が参照する `git-prompt.sh` と `git-completion.sh` は、Home ManagerでインストールするGit packageから参照する。

### Git

- Git設定はHome Managerの `programs.git` で管理する。
- `user.name = KAKUDO Kentaro` を維持する。
- `user.email = 31888089+kakudo415@users.noreply.github.com` を維持する。
- `core.editor = nvim` を維持する。
- Git ignore設定を維持する。
- GPG署名設定は移行せず、署名設定を含まない `programs.git` を構成する。

### tmux

- 既存のprefix、pane移動、pane resize、index、history、status line、色設定を維持する。

### Neovim

- 既存の `init.vim` の設定内容を維持する。
- Neovim本体をHome Managerで管理する場合も、既存設定の配置先は `~/.config/nvim/init.vim` とする。

### GDB

- `set disassembly-flavor intel` を維持する。

### Ghostty

- 既存のfont、font size、background opacity、background blur設定を維持する。

### Claude

- 既存の環境変数設定と `includeCoAuthoredBy = false` を維持する。

## 非機能要件

- 秘密情報、秘密鍵、トークンをGit管理対象やNix storeに含めない。
- 移行対象外に定めるものを除き、既存chezmoi出力と同じ設定ファイルとソフトウェアを用意できるようにする。
- Nix設定は責務単位で分割し、単一ファイルに過度に集約しない。
- `nix flake check` が成功することを検証条件とする。
- `home-manager build` が成功することを検証条件とする。
