# Claude Code and Codex Settings

## 背景

このリポジトリはNix FlakesとHome Managerでdotfilesを管理している。
導入前は、Claude Codeの `~/.claude/settings.json` を `home.file` で管理していたが、Claude Code本体やCodexの設定はHome Manager moduleとしては管理していなかった。

Claude CodeとCodex GUIを併用する場合、エージェント向けの共通プロンプト、CLI package、静的設定、GUIが更新する動的状態を分けて扱わないと、設定の二重管理やGUI設定ファイルの上書きが起きやすい。

Home Managerには `programs.claude-code` moduleがあるため、Claude Codeは個別の `home.file` ではなく標準moduleで管理する。
Codexは本体や設定をHome Managerで導入せず、Codex GUIが読み込む `~/.codex/AGENTS.md` の配置のみを管理する。
また、Claude Codeのpackageは `numtide/llm-agents.nix` 由来のものを使い、日々更新されるAI agent CLIのreleaseへ追従しやすくする。

## 要求事項

- Claude Code本体をHome Managerで導入する。
- Claude Codeのpackageは `numtide/llm-agents.nix` 由来のものを使用する。
- Claude Codeの既存設定を維持する。
- Claude CodeとCodexの共通プロンプトを単一のsource of truthとして管理する。
- Codex CLI本体、Codex設定、Codex GUIが更新する動的状態はHome Managerで固定しない。
- 秘密情報、認証情報、token、session、cache、logをGit管理対象やNix storeに含めない。
- MCP server、Agent Skills、subagent、拒否コマンドリストの本格的なSSOT化はこの機能に含めない。

## 機能要件

### Flake inputs

- `flake.nix` に `llm-agents` inputを追加する。
- `llm-agents.url` は `github:numtide/llm-agents.nix` とする。
- `llm-agents.inputs.nixpkgs.follows = "nixpkgs"` は設定しない。
- `pkgs` import時に `llm-agents.overlays.default` を適用する。
- `pkgs.llm-agents.claude-code` をHome Manager moduleのpackageとして参照できるようにする。

### Binary cache

- `flake.nix` の `nixConfig.extra-substituters` に `https://cache.numtide.com` を追加する。
- `flake.nix` の `nixConfig.extra-trusted-public-keys` に `niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=` を追加する。
- Binary cacheの追加はbuild高速化を目的とし、cacheが利用できない場合も通常buildで検証できる構成にする。

### Shared agent prompt

- `home/agents/PROMPT.md` を追加する。
- `home/agents/PROMPT.md` をClaude CodeとCodexの共通プロンプトのsource of truthとする。
- 共通プロンプトには、ホームディレクトリ配下のClaude CodeとCodexで共通利用する一般的な作業方針を記載する。
- 共通プロンプトは英語で記述し、タイトルは `Basic Principles` とする。
- 共通プロンプトには次の原則を含める。
  - sessionに閉じた情報をコードコメント、PR説明、commit message、documentationなどの外部artifactに漏らさない。
  - コードコメントには読めば分かる処理内容ではなく、理由、背景、制約、非自明なtradeoffを書く。
  - 検討した候補、最終決定、実際に実施または実装したことを明確に区別する。
  - 技術的な質問を遠回しな指示として扱わず、質問と指示を明確に区別する。
  - 変更後の成果物には最終状態だけを残し、古い状態や途中経過を残さない。
- 共通プロンプトには秘密情報を含めない。
- 共通プロンプトは行動ガイドとして扱い、強制的な拒否ルールは含めない。

### Claude Code

- `home/claude.nix` は廃止し、Claude Code設定は `home/agents/claude-code.nix` に移動する。
- `home/agents/claude-code.nix` は `programs.claude-code` を使って管理する。
- `programs.claude-code.enable = true` を設定する。
- `programs.claude-code.package = pkgs.llm-agents.claude-code` を設定する。
- `programs.claude-code.context` は `home/agents/PROMPT.md` を参照する。
- `programs.claude-code.settings` で既存の `~/.claude/settings.json` 相当の設定を管理する。
- `programs.claude-code.settings.env.EDITOR = "nvim"` を設定する。
- `programs.claude-code.settings.env.DISABLE_AUTOUPDATER = 1` を設定する。
- `programs.claude-code.settings.env.DISABLE_ERROR_REPORTING = 1` を設定する。
- `programs.claude-code.settings.env.DISABLE_TELEMETRY = 1` を設定する。
- `programs.claude-code.settings.attribution.commit = ""` を設定し、Git commitのattributionを出力しない。
- `programs.claude-code.settings.attribution.pr = ""` を設定し、Pull Requestのattributionを出力しない。
- `programs.claude-code.settings.attribution.sessionUrl = false` を設定し、Git commitにsession URL trailerを出力しない。
- `programs.claude-code.settings.language = "japanese"` を設定する。
- `programs.claude-code.settings.permissions.allow` に一般的な確認系コマンドのallow listを設定する。
- allow listは作業ディレクトリ確認、一覧表示、Gitの確認系、Git commit、GitHub CLIの読み取り系コマンドに限定する。
- GitHub CLIのallow listには、認証状態、repo、issue、pull request、workflow、run、releaseの確認系コマンドを含める。
- allow listにはNix関連コマンドを含めない。
- allow listには削除、push、checkout、merge、edit、外部公開を行うコマンドを含めない。
- `home.file.".claude/settings.json"` による直接管理は廃止する。

### Codex

- 新規module fileとして `home/agents/codex.nix` を追加する。
- `home/agents/default.nix` を追加し、`home/agents/claude-code.nix` と `home/agents/codex.nix` をimportする。
- `home/default.nix` は `home/agents` をimportする。
- Codex CLI本体はHome Managerで導入しない。
- `programs.codex` は設定しない。
- `home.file.".codex/AGENTS.md".source = ./PROMPT.md` を設定する。
- `~/.codex/config.toml` やその他のCodex関連ファイルはCodex GUIが更新する動的設定または状態として扱い、Home Managerで生成または置換しない。

### Codex managed and unmanaged files

- Home Manager管理対象に含めるCodex関連ファイルは `~/.codex/AGENTS.md` のみとする。
- `~/.codex/AGENTS.md` 以外のCodex関連ファイルやディレクトリはHome Manager管理対象に含めない。
- Codex GUIのproject trust、plugin有効化、marketplace更新時刻、approval rulesはこの機能では管理しない。

## 非機能要件

- Claude Code設定は `programs.claude-code` を使う。
- CodexはCLI本体や設定を管理せず、`~/.codex/AGENTS.md` の配置のみを管理する。
- Claude CodeとCodexの共通プロンプトは一箇所で編集できるようにする。
- Claude Codeのpermission bypass modeはこの機能では固定しない。
- Codex GUIが実行中または終了時に更新するファイルをread-only symlinkに置き換えない。
- `llm-agents.nix` はpackage供給元として使用し、設定ファイル生成はHome Manager moduleに任せる。
- `llm-agents.nix` の追加によって既存の `nixpkgs` inputやHome Manager inputの追従関係を変更しない。
- 秘密情報、認証情報、token、session、cache、log、local stateをGit管理対象やNix storeに含めない。
- 拒否コマンド、MCP server、Agent Skills、subagentは後続機能で扱えるよう、今回の実装では独自SSOT構造を作らない。

## 検証

- ローカルで `nix flake check` が成功すること。
- ローカルで `nix build --no-link --print-out-paths .#homeConfigurations.kakudo.activationPackage` が成功すること。
- Home Manager buildが成功すること。
- 評価結果で `programs.claude-code.enable = true` になっていること。
- 評価結果で `programs.claude-code.package` が `pkgs.llm-agents.claude-code` を参照していること。
- 評価結果で `programs.codex.enable` が有効化されていないこと。
- 生成されるClaude Codeの `settings.json` に `env.EDITOR = "nvim"` が含まれること。
- 生成されるClaude Codeの `settings.json` に `env.DISABLE_AUTOUPDATER = 1` が含まれること。
- 生成されるClaude Codeの `settings.json` に `env.DISABLE_ERROR_REPORTING = 1` が含まれること。
- 生成されるClaude Codeの `settings.json` に `env.DISABLE_TELEMETRY = 1` が含まれること。
- 生成されるClaude Codeの `settings.json` に `attribution.commit = ""` が含まれること。
- 生成されるClaude Codeの `settings.json` に `attribution.pr = ""` が含まれること。
- 生成されるClaude Codeの `settings.json` に `attribution.sessionUrl = false` が含まれること。
- 生成されるClaude Codeの `settings.json` に `language = "japanese"` が含まれること。
- 生成されるClaude Codeの `settings.json` に確認系コマンドとGitHub CLIの読み取り系コマンドの `permissions.allow` が含まれること。
- 生成されるClaude Codeの `settings.json` の `permissions.allow` にNix関連コマンドが含まれないこと。
- 生成されるClaude Codeの `settings.json` の `permissions.allow` に削除、push、checkout、merge、edit、外部公開を行うコマンドが含まれないこと。
- `~/.claude/CLAUDE.md` が `home/agents/PROMPT.md` の内容を反映すること。
- `~/.codex/AGENTS.md` が `home/agents/PROMPT.md` の内容を反映すること。
- `~/.codex/config.toml` がHome Manager管理のsymlinkに置き換わらないこと。
- `~/.codex/AGENTS.md` 以外のCodex関連ファイルやディレクトリがHome Manager管理対象に含まれないこと。
