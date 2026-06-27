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
  - GDB設定
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
- Home Manager設定は責務単位で分割し、プログラムごとに独立したmodule fileとして管理する。

### Packages

- Home Managerで次のソフトウェアを用意する。
  - `git`
  - `zsh`
  - `bash`
  - `tmux`
  - `neovim`
  - `ghostty-bin`
  - `lsd`
- `git`、`zsh`、`bash`、`tmux`、`neovim` は可能な限り対応する `programs.*` moduleによって導入する。
- `ghostty` は `aarch64-darwin` で利用可能なNixpkgs packageとして `ghostty-bin` を使用する。
- Cica fontはHome Managerで用意する対象に含める。
- Cica fontがNixpkgs packageとして利用できない場合、リポジトリ内にCica用packageを定義する。
- Cica font sourceは `https://github.com/miiton/Cica/releases/download/v5.0.3/Cica_v5.0.3.zip` とする。
- Cica font source hashは `sha256-BtDnfWCfD9NE8tcWSmk8ciiInsspNPTPmAdGzpg62SM=` とする。
- Cica fontは `~/Library/Fonts` に配置され、macOSアプリケーションから参照できるようにする。

### Shell

- Zshのprompt、Git branch表示、aliasを維持する。
- Zsh設定は `~/.config/zsh/.zshrc` に配置する。
- Zshが `~/.config/zsh/.zshrc` を読むために必要な `~/.zshenv` はHome Managerで管理する。
- Bashのinteractive判定、prompt、Git branch表示、履歴設定、aliasを維持する。
- `lsd` はHome Managerで導入されるため、Bash/Zshとも `ls` aliasは無条件に `lsd` へ設定する。
- `~/.cargo/env` の読み込みは移行しない。
- `~/.zshrc.local` の読み込みは移行しない。
- 既存設定が参照する `git-prompt.sh` と `git-completion.sh` は、Home ManagerでインストールするGit packageから参照する。
- Bash/Zshのalias、履歴、shell optionなど、Home Manager moduleで表現できる設定は `programs.bash` / `programs.zsh` の設定として管理する。
- Promptなど標準moduleで表現しづらい設定のみ、各shell moduleの追加設定として管理する。

### Git

- Git設定はHome Managerの `programs.git` で管理する。
- `user.name = KAKUDO Kentaro` を維持する。
- `user.email = 31888089+kakudo415@users.noreply.github.com` を維持する。
- `core.editor = nvim` を維持する。
- Git ignore設定を維持する。
- GPG署名設定は移行せず、署名設定を含まない `programs.git` を構成する。

### tmux

- 既存のprefix、pane移動、pane resize、index、history、status line、色設定を維持する。
- tmux本体とHome Manager moduleで表現できる設定は `programs.tmux` で管理する。
- `prefix`、`baseIndex`、`escapeTime`、`historyLimit`、`keyMode`、pane移動、pane resizeは `programs.tmux` のmodule optionで管理する。
- status line、色、pane borderなどmodule optionで表現しづらい設定のみ `programs.tmux.extraConfig` で管理する。

### Neovim

- 既存の `init.vim` の設定内容を維持する。
- Neovim本体は `programs.neovim` で管理する。
- 既存の `init.vim` の設定内容は `programs.neovim.extraConfig` で管理する。
- Home ManagerがNeovim用の `init.lua` を `~/.config/nvim/init.lua` として配置しないようにする。
- `~/.config/nvim/init.vim` を直接配置することは要求しない。

### Ghostty

- 既存のfont、font size、background opacity、background blur設定を維持する。

### Claude

- 既存の環境変数設定と `includeCoAuthoredBy = false` を維持する。
- 既存chezmoi管理対象である `~/.claude/settings.json` のみを移行対象とする。

## 非機能要件

- 秘密情報、秘密鍵、トークンをGit管理対象やNix storeに含めない。
- 移行対象外に定めるもの、およびHome Manager module管理へ寄せるために配置先が変わるものを除き、既存chezmoi出力と同等の設定とソフトウェアを用意できるようにする。
- Nix設定は責務単位で分割し、単一ファイルに過度に集約しない。
- `nix flake check` が成功することを検証条件とする。
- `home-manager build` が成功することを検証条件とする。
- 初回適用手順は `nix run github:nix-community/home-manager/release-26.05 -- switch --flake .#kakudo` とする。
- 検証時に `apps.aarch64-darwin.home-manager` のような補助outputは定義しない。
