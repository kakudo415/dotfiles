# Claude Code and Codex Mutable Settings

## 背景

このリポジトリはNix FlakesとHome ManagerでClaude CodeとCodex向けの共通プロンプトや静的設定を管理している。
`004-claude-codex-settings` ではClaude Codeの `settings.json` 相当を `programs.claude-code.settings` で管理する方針にした。

しかし、Claude Codeの `~/.claude/settings.json` はClaude Code本体がplugin install / enable / disableやuser preferenceの保存先として更新するmutable fileである。
このファイルをHome Manager管理の生成物またはsymlinkにすると、Claude Codeが実行中に設定を書き込めず、コマンド内で編集した内容やユーザー操作による設定変更が保存されない。

Codexの `~/.codex/config.toml` もCodex CLI、Codex GUI、IDE連携が更新する可能性があるため、同様にHome Manager管理の生成物として固定しない。

## 要求事項

- `~/.claude/settings.json` はNix管理しない。
- `~/.claude/settings.json` はClaude Codeが更新するmutable fileとして残す。
- Nixで管理したいClaude Code設定は `~/.claude/settings.nix.json` に出力する。
- `claude` コマンドはNix管理設定を読むように起動する。
- `~/.codex/config.toml` は原則Nix管理しない。
- Claude CodeとCodexの共通プロンプト管理は維持する。
- Claude Codeの既存のNix管理設定値は `settings.nix.json` に移す。
- 秘密情報、認証情報、token、session、cache、log、local stateをGit管理対象やNix storeに含めない。

## 検討した選択肢

### `~/.claude/settings.json` を引き続きNix管理する

採用しない。
Claude Code本体がこのファイルを書き換える前提のため、Home Manager管理の生成物にするとmutable fileとして利用できない。

### shell aliasで `claude --settings ~/.claude/settings.nix.json` を起動する

採用しない。
対話shellからの起動には有効だが、shell aliasが効かない起動経路ではNix管理設定が読み込まれない。

### wrapperで `claude --settings ~/.claude/settings.nix.json` を起動する

採用する。
Home Managerが配置する `claude` コマンド自体をwrapperにし、対話shell以外の起動経路でもNix管理設定を読み込む。

## 最終決定

- Claude Code本体の実体packageは引き続き `pkgs.llm-agents.claude-code` を使用する。
- ユーザーが実行する `claude` コマンドはwrapperとして配置する。
- wrapperは実体packageの `claude` を `--settings "$HOME/.claude/settings.nix.json"` 付きで実行する。
- `~/.claude/settings.nix.json` はHome Managerで生成する。
- `~/.claude/settings.json` はHome Managerで生成、置換、削除しない。
- `programs.claude-code.settings` による `settings.json` 生成は使わない。
- `~/.codex/config.toml` はHome Managerで生成、置換、削除しない。

## 機能要件

### Claude Code package

- `pkgs.llm-agents.claude-code` をClaude Code本体の供給元として維持する。
- wrapper packageを定義し、ユーザーに公開する実行ファイル名を `claude` とする。
- wrapperは `pkgs.llm-agents.claude-code` の実体 `claude` を絶対pathで実行する。
- wrapperは常に `--settings "$HOME/.claude/settings.nix.json"` を付与する。
- wrapperはユーザーが指定した引数をそのまま実体 `claude` に渡す。
- wrapperは `settings.nix.json` を編集、生成、削除しない。
- wrapperは `~/.claude/settings.json` を編集、生成、削除しない。

### Claude Code managed files

- `~/.claude/settings.nix.json` をHome Managerで生成する。
- `~/.claude/settings.nix.json` の内容はNix式内のJSON attrsetから生成する。
- `~/.claude/settings.nix.json` には既存のNix管理Claude Code設定を含める。
- `~/.claude/settings.nix.json` には `env.EDITOR = "nvim"` を含める。
- `~/.claude/settings.nix.json` には `env.DISABLE_AUTOUPDATER = 1` を含める。
- `~/.claude/settings.nix.json` には `env.DISABLE_ERROR_REPORTING = 1` を含める。
- `~/.claude/settings.nix.json` には `env.DISABLE_TELEMETRY = 1` を含める。
- `~/.claude/settings.nix.json` には `attribution.commit = ""` を含める。
- `~/.claude/settings.nix.json` には `attribution.pr = ""` を含める。
- `~/.claude/settings.nix.json` には `attribution.sessionUrl = false` を含める。
- `~/.claude/settings.nix.json` には `effortLevel = "xhigh"` を含める。
- `~/.claude/settings.nix.json` には `language = "japanese"` を含める。
- `~/.claude/settings.nix.json` には `theme = "dark"` を含める。
- `~/.claude/settings.nix.json` には既存の `permissions.allow` を含める。
- `~/.claude/CLAUDE.md` は引き続き `home/agents/PROMPT.md` の内容を反映する。
- `~/.claude/settings.json` はHome Manager管理対象に含めない。

### Claude Code unmanaged files

- `~/.claude/settings.json` はClaude Code本体が更新するmutable fileとして扱う。
- `~/.claude/settings.json` にplugin install / enable / disableやuser preferenceが保存されても、Home Manager activationで上書きしない。
- `~/.claude/settings.json` が存在しない環境でもHome Manager activationは成功する。
- `~/.claude/settings.json` が既に存在する環境では、その内容を保持する。
- `~/.claude/settings.json` の内容をGit管理対象やNix storeに取り込まない。
- Claude Codeのsession、cache、log、token、local stateはHome Manager管理対象に含めない。

### Codex

- `home.file.".codex/AGENTS.md".source = ./PROMPT.md` は維持する。
- `~/.codex/AGENTS.md` は引き続き `home/agents/PROMPT.md` の内容を反映する。
- `programs.codex` は設定しない。
- Codex CLI本体はHome Managerで導入しない。
- `~/.codex/config.toml` はHome Manager管理対象に含めない。
- `~/.codex/config.toml` がCodex CLI、Codex GUI、IDE連携によって更新されても、Home Manager activationで上書きしない。
- `~/.codex/config.toml` が存在しない環境でもHome Manager activationは成功する。
- `~/.codex/AGENTS.md` 以外のCodex関連ファイルやディレクトリはHome Manager管理対象に含めない。

## 非機能要件

- Claude CodeとCodexが実行中または終了時に更新するファイルをread-only symlinkに置き換えない。
- Nix管理の静的設定とツール本体が更新するmutable fileを明確に分離する。
- wrapperは追加の状態を持たず、起動引数の付与だけを行う。
- Nix設定は責務単位で分割し、Claude Code設定とCodex設定の責務を混在させない。
- 既存の共通プロンプトのsource of truthは `home/agents/PROMPT.md` のままとする。
- 秘密情報、認証情報、token、session、cache、log、local stateをGit管理対象やNix storeに含めない。

## 検証

- ローカルで `nix flake check` が成功すること。
- ローカルで `nix build --no-link --print-out-paths .#homeConfigurations.kakudo.activationPackage` が成功すること。
- Home Manager buildが成功すること。
- 生成されるHome Manager filesに `~/.claude/settings.nix.json` が含まれること。
- 生成されるHome Manager filesに `~/.claude/settings.json` が含まれないこと。
- 生成されるHome Manager filesに `~/.claude/CLAUDE.md` が含まれること。
- `claude` コマンドがwrapperとして配置されること。
- wrapper内で実体 `claude` が `--settings "$HOME/.claude/settings.nix.json"` 付きで実行されること。
- `~/.claude/settings.nix.json` に既存のNix管理Claude Code設定値が含まれること。
- 既存の `~/.claude/settings.json` がHome Manager activationで上書きされないこと。
- `~/.claude/settings.json` が存在しない環境でもHome Manager activationが成功すること。
- `~/.codex/AGENTS.md` が `home/agents/PROMPT.md` の内容を反映すること。
- 生成されるHome Manager filesに `~/.codex/config.toml` が含まれないこと。
- 既存の `~/.codex/config.toml` がHome Manager activationで上書きされないこと。
- `~/.codex/config.toml` が存在しない環境でもHome Manager activationが成功すること。
