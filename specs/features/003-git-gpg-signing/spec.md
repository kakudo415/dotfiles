# Git GPG Signing

## 背景

このリポジトリはNix FlakesとHome ManagerでGit設定を管理している。
現在の `programs.git` にはGPG署名設定がなく、commitやtagをデフォルトで署名できない。

Git、GnuPG、gpg-agent、pinentry-macをHome Manager管理に含め、Git commitとGit tagをGPG署名できるようにする。

## 要求事項

- Git設定は引き続きHome Managerの `programs.git` で管理する。
- GnuPG、gpg-agent、pinentry-macはHome Managerで管理する。
- Git commitとGit tagはデフォルトでGPG署名する。
- 署名方式はOpenPGP/GnuPGを使用する。
- 既存GPG鍵がある場合は既存鍵を使用する。
- Gitの署名鍵IDはNix設定に固定しない。
- machine-localなGit設定をGit管理対象外のlocal configで追加できるようにする。
- 初回セットアップ手順として、GPG鍵の確認、必要な場合の鍵生成、GitHubへの公開鍵登録、署名確認手順をREADMEに記載する。
- 秘密鍵、passphrase、GitHub tokenはGit管理対象やNix storeに含めない。
- GitHubへのGPG key登録をHome Manager activationで実行しない。
- GitHub APIやGitHub CLIによるGPG key自動登録はこの機能に含めない。

## 機能要件

### Packages

- Home Managerで `pinentry-mac` を用意する。
- Nixpkgs packageとしては `pkgs.pinentry_mac` を使用する。

### GnuPG

- `programs.gpg.enable = true` を設定する。
- GnuPG packageはHome Managerの `programs.gpg` moduleで管理する。
- GPG homedirはHome Manager moduleのdefaultを使用する。
- GPG秘密鍵、公開鍵、trust databaseはHome Managerで生成または配置しない。

### gpg-agent

- `services.gpg-agent.enable = true` を設定する。
- `services.gpg-agent.pinentry.package = pkgs.pinentry_mac` を設定する。
- `services.gpg-agent.enableBashIntegration = true` を設定する。
- `services.gpg-agent.enableZshIntegration = true` を設定する。
- SSH agentとしての利用はこの機能に含めない。

### Git

- 既存の `user.name = KAKUDO Kentaro` を維持する。
- 既存の `user.email = 31888089+kakudo415@users.noreply.github.com` を維持する。
- 既存の `core.editor = nvim` を維持する。
- 既存のGit ignore設定を維持する。
- `programs.git.signing.format = "openpgp"` を設定する。
- `programs.git.signing.signByDefault = true` を設定する。
- `programs.git.signing.key = null` を設定し、`user.signingkey` をGit configに出力しない。
- 署名鍵はGit/GnuPGがcommit author emailに対応する秘密鍵から選択する。
- `${config.xdg.configHome}/git/config.local` をGit configの末尾でincludeする。
- `${config.xdg.configHome}/git/config.local` はHome Managerで作成しない。

### Documentation

- READMEにGPG署名セットアップ手順を追加する。
- READMEにlocal Git configの配置先と用途を記載する。
- 手順には既存秘密鍵の確認方法を含める。
- 手順には秘密鍵がない場合のGPG鍵生成方法を含める。
- 手順にはGitHubへ登録する公開鍵のexport方法を含める。
- 手順にはGitHub上でGPG keyを登録する操作を含める。
- 手順には署名付きcommitの作成確認方法を含める。

## 非機能要件

- 秘密情報、秘密鍵、passphrase、GitHub tokenをGit管理対象やNix storeに含めない。
- Home Manager activationは外部サービスへの書き込みを行わない。
- GPG鍵の作成、削除、更新、失効、trust設定はHome Manager activationで行わない。
- 既存のGit、Bash、Zsh設定の挙動を署名に必要な変更を除いて維持する。
- Nix設定は責務単位で分割し、Git設定とGPG agent設定の責務を混在させない。

## 検証

- ローカルで `nix flake check` が成功すること。
- ローカルで `nix build --no-link --print-out-paths .#homeConfigurations.kakudo.activationPackage` が成功すること。
- Home Manager buildが成功すること。
- 生成されるGit configに `commit.gpgsign = true` が含まれること。
- 生成されるGit configに `tag.gpgSign = true` が含まれること。
- 生成されるGit configに `gpg.format = openpgp` が含まれること。
- 生成されるGit configに `user.signingkey` が含まれないこと。
- 生成されるGit configにXDG config home配下の `git/config.local` へのincludeが含まれること。
- gpg-agent設定でpinentry programとして `pinentry-mac` が指定されること。
- GPG鍵とGitHub登録を用意した環境で、署名付きcommitを作成できること。
