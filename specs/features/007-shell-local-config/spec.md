# Shell Local Config

## 背景

このリポジトリはNix FlakesとHome ManagerでBash/Zsh設定を管理している。
Nix管理の設定は再現性がある一方で、端末や外部インストーラーが追加するmachine localなshell設定はGit管理やNix storeに含めたくない。

Zshは `ZDOTDIR` を `~/.config/zsh` に設定しているため、通常の起動時に `~/.zshrc` は自動では読まれない。
この性質を利用し、`~/.zshrc` をZshのlocal専用設定として扱う。

Bashは `~/.bashrc` をHome Managerで管理しており、login shell用の `~/.bash_profile` からも読み込まれる。
そのため、Bashのlocal設定は `~/.bashrc` ではなく別ファイルに分離する。

## 要求事項

- Nix管理のBash/Zsh設定は維持する。
- ZshはNix管理の `~/.config/zsh/.zshrc` の最後にlocal設定を読み込む。
- Zshのlocal設定ファイルは `~/.zshrc` とする。
- BashはNix管理の `~/.bashrc` の最後にlocal設定を読み込む。
- Bashのlocal設定ファイルは `~/.bashrc.local` とする。
- local設定ファイルが存在しない環境でもshell起動時にエラーにしない。
- local設定ファイルの内容はGit管理対象やNix storeに含めない。

## 機能要件

### Zsh

- `programs.zsh.dotDir = "${config.xdg.configHome}/zsh"` は維持する。
- Nix管理のZsh設定は引き続き `~/.config/zsh/.zshrc` に生成する。
- `~/.config/zsh/.zshrc` の最後で、読み取り可能な `~/.zshrc` が存在する場合のみ読み込む。
- `~/.zshrc` が存在しない、または読み取り不能な場合は読み込まない。

### Bash

- Nix管理のBash設定は引き続き `~/.bashrc` に生成する。
- `~/.bash_profile` から `~/.bashrc` を読み込む既存挙動は維持する。
- `~/.bashrc` の最後で、読み取り可能な `~/.bashrc.local` が存在する場合のみ読み込む。
- `~/.bashrc.local` が存在しない、または読み取り不能な場合は読み込まない。

## 非機能要件

- local設定の読み込みはBash/Zshの既存prompt、alias、history設定の後に行う。
- Home Manager activationでlocal設定ファイルを作成、置換、削除しない。
- 秘密情報、認証情報、token、session、cache、log、local stateをGit管理対象やNix storeに含めない。
- 変更はlocal設定読み込みの追加に限定する。

## 検証

- ローカルで `nix flake check --show-trace` が成功すること。
- ローカルで `nix build --no-link --print-out-paths .#homeConfigurations.kakudo.activationPackage` が成功すること。
- 生成される `~/.config/zsh/.zshrc` に `~/.zshrc` の条件付き読み込みが含まれること。
- 生成される `~/.bashrc` に `~/.bashrc.local` の条件付き読み込みが含まれること。
- 生成されるHome Manager filesに `~/.zshrc` が含まれないこと。
- 生成されるHome Manager filesに `~/.bashrc.local` が含まれないこと。
