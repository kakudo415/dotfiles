# chezmoi管理dotfilesのNix移行仕様

## 背景

このリポジトリは現在、chezmoiのソース形式でdotfilesを管理している。Nix、Home Manager、Nix Flakesを使う構成へ移行し、chezmoiで管理しているdotfilesをNix管理へ置き換える。

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
| `dot_claude/settings.json` | `~/.claude/settings.json` | Claude設定 |
| `.chezmoi.toml.tmpl` | chezmoi設定 | GPG key IDの入力に使用 |
| `.chezmoiignore` | chezmoi除外 | README/LICENSEを除外 |

`dot_config/sura/config.json` は今後使用しないため、Nix移行対象には含めない。

## 要求事項

- 現在chezmoiで管理しているdotfilesをNix管理へ移行する。
- 移行後はHome Managerのactivationによって対象dotfilesが配置される。
- Nix Flakesを導入し、Nix Flakes inputsを `flake.lock` で固定する。
- Home ManagerはNix Flakesの `homeConfigurations` outputから利用できるようにする。
- 既存dotfilesの挙動を維持する。
- Sura設定は移行せず、chezmoi管理からも削除できる状態にする。
- GPG key IDのような個人差分は、秘密情報としてリポジトリに固定しない。

## 機能要件

### Nix Flakes

- リポジトリルートに `flake.nix` を配置する。
- `nixpkgs` と `home-manager` をNix Flakes inputsとして定義する。
- `home-manager.inputs.nixpkgs.follows = "nixpkgs"` を設定する。
- `flake.lock` をコミット対象にする。
- `homeConfigurations` に現在ユーザー向けのHome Manager構成を定義する。
- `nix flake check` でHome Manager構成の評価確認ができるようにする。

### Home Manager

- `home.username`、`home.homeDirectory`、`home.stateVersion` を明示する。
- `programs.home-manager.enable = true` を設定する。
- 標準moduleで表現できる設定はHome Managerのmoduleで管理する。
- 標準moduleで表現しづらい設定は `home.file` または `xdg.configFile` で管理する。

### Shell

- Zshのprompt、Git branch表示、aliasを維持する。
- Bashのinteractive判定、prompt、Git branch表示、履歴設定、aliasを維持する。
- `lsd` が利用可能な場合に `ls` aliasを切り替える挙動を維持する。
- 既存の `~/.cargo/env` 読み込み互換を維持する。
- 既存設定が参照する `git-prompt.sh` と `git-completion.sh` の供給方法をNix側で定義する。

### Git

- `user.name = KAKUDO Kentaro` を維持する。
- `user.email = 31888089+kakudo415@users.noreply.github.com` を維持する。
- `core.editor = nvim` を維持する。
- GPG key IDが設定されている場合のみ、`user.signingkey`、`gpg.program`、`commit.gpgsign` を有効化する。
- GPG key ID未設定時もGit設定が有効に評価・配置される。
- Git ignore設定を維持する。

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

- 再現性: Nix Flakes inputsは `flake.lock` で固定する。
- 安全性: 秘密情報、秘密鍵、トークンをGit管理対象やNix storeに含めない。
- 可逆性: 移行が完了するまで、既存chezmoi運用へ戻れる状態を維持する。
- 最小変更: 既存dotfilesの意味を変えず、Nix化に必要な変更に限定する。
- 検証可能性: Nix評価、Home Manager build、既存chezmoi出力との差分確認を実施できるようにする。
- 拡張性: 将来ホスト差分、OS差分、ユーザー差分を追加できる構成にする。
- 可読性: Nix設定は責務単位で分割し、単一ファイルに過度に集約しない。
