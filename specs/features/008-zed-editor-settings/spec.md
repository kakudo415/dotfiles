# Zed Editor Settings

## 背景

このリポジトリはNix FlakesとHome Managerでdotfilesを管理している。
ZedはNixpkgsに `pkgs.zed-editor` として存在するが、現在のNixpkgs定義はRust source buildであり、macOSローカル環境で導入するとbuild時間が大きくなる。

一方で、Home Managerには `programs.zed-editor` moduleがあり、Zed本体のpackageとは独立して `settings.json`、`keymap.json`、`tasks.json`、`debug.json` の管理に使える。
`programs.zed-editor.package = null` を指定すれば、Home Manager moduleを使いながらZed本体を `home.packages` に追加しない構成にできる。

Zed本体のインストール方法は別仕様または運用手順で決める。
ここではZedのユーザー設定だけをHome Managerで管理し、Zed本体はHomebrew cask、手動インストール、その他の方法で別途導入できる状態にする。

## 参考資料

- Zedの設定項目は <https://zed.dev/docs/reference/all-settings> を参照する。
- Zedのkeymap形式は <https://zed.dev/docs/key-bindings> を参照する。
- Zedのextension名は <https://github.com/zed-industries/extensions/tree/main/extensions> を参照する。
- Zed本体の導入方針は `adr/zed-installation-method.md` を参照する。
- Zed設定ファイルの管理方針は `adr/zed-settings-management.md` を参照する。

## 要求事項

- Zed本体はHome Managerで導入しない。
- `pkgs.zed-editor` のlocal source buildを発生させない。
- Zed設定はHome Managerの `programs.zed-editor` moduleで管理する。
- エディタ関連moduleは `home/editors` 配下にまとめる。
- 既存のNeovim設定は挙動を維持したまま `home/editors` 配下に移す。
- Zed設定は `home/editors/zed.nix` として分離して管理する。
- `home/default.nix` から `./editors` をimportする。
- `programs.zed-editor.enable = true` を設定する。
- `programs.zed-editor.package = null` を必ず設定する。
- Zed本体のインストール方法はこの仕様では決めない。
- ZedのUIやcommand paletteから行う設定変更を可能な限り維持する。
- Nix管理したい共通設定はHome Manager activation時にZed設定へmergeする。
- 秘密情報、認証情報、token、session、cache、log、local stateをGit管理対象やNix storeに含めない。

## 非対象

- Zed本体をインストールすること。
- Homebrew cask、手動インストール、Nix導入のどれを使うか決めること。
- nix-darwinまたはHomebrew管理をこのリポジトリへ追加すること。
- `pkgs.zed-editor` を `home.packages` に追加すること。
- Zedをdefault editorとして `EDITOR` または `VISUAL` に設定すること。
- Zed remote serverを導入または設定すること。
- Zed MCP integrationを有効化すること。
- AI provider、account、billing、login、API key、tokenを設定すること。
- Zedのsession、cache、log、local stateを管理すること。
- 言語別overrideを追加すること。
- Neovim設定の内容や生成結果を変更すること。

## 機能要件

### Module structure

- `home/editors/default.nix` を追加する。
- `home/editors/default.nix` からNeovim moduleとZed moduleをimportする。
- 既存の `home/neovim.nix` は `home/editors/neovim.nix` に移動する。
- `home/default.nix` は `./neovim.nix` ではなく `./editors` をimportする。
- `home/default.nix` は `./zed.nix` または `./editors/zed.nix` を直接importしない。
- Neovimの `programs.neovim` 設定内容は変更しない。

### Home Manager module

- `programs.zed-editor.enable = true` を設定する。
- `programs.zed-editor.package = null` を設定する。
- `programs.zed-editor.defaultEditor` は設定しない。
- `programs.zed-editor.extraPackages` は設定しない。
- `programs.zed-editor.installRemoteServer` は設定しない。
- `programs.zed-editor.enableMcpIntegration` は設定しない。
- `programs.zed-editor.mutableUserSettings` は既定値の `true` を維持する。
- `programs.zed-editor.mutableUserKeymaps` は既定値の `true` を維持する。
- `programs.zed-editor.mutableUserTasks` は既定値の `true` を維持する。
- `programs.zed-editor.mutableUserDebug` は既定値の `true` を維持する。

### Keymap and editing mode

- `programs.zed-editor.userSettings.base_keymap = "VSCode"` を設定する。
- `programs.zed-editor.userSettings.vim_mode = false` を設定する。
- `programs.zed-editor.userKeymaps` は設定しない。

### Appearance

- `programs.zed-editor.userSettings.buffer_font_family = "Cica"` を設定する。
- `programs.zed-editor.userSettings.buffer_font_size = 14` を設定する。
- `programs.zed-editor.userSettings.ui_font_family = "Cica"` を設定する。
- `programs.zed-editor.userSettings.ui_font_size = 16` を設定する。
- `programs.zed-editor.userSettings.theme.mode = "system"` を設定する。
- `programs.zed-editor.userSettings.theme.dark = "One Dark"` を設定する。
- `programs.zed-editor.userSettings.theme.light = "One Light"` を設定する。
- `programs.zed-editor.userSettings.icon_theme.mode = "system"` を設定する。
- `programs.zed-editor.userSettings.icon_theme.dark = "Zed (Default)"` を設定する。
- `programs.zed-editor.userSettings.icon_theme.light = "Zed (Default)"` を設定する。

### Save behavior

- `programs.zed-editor.userSettings.autosave = "off"` を設定する。
- `programs.zed-editor.userSettings.format_on_save = "off"` を設定する。
- `programs.zed-editor.userSettings.ensure_final_newline_on_save = true` を設定する。
- `programs.zed-editor.userSettings.remove_trailing_whitespace_on_save = true` を設定する。

### Display helpers

- `programs.zed-editor.userSettings.show_wrap_guides = true` を設定する。
- `programs.zed-editor.userSettings.wrap_guides = [ 80 100 ]` を設定する。
- `inlay_hints` は設定しない。
- `show_whitespaces` は設定しない。
- `colorize_brackets` は設定しない。

### Privacy and AI

- `programs.zed-editor.userSettings.telemetry.diagnostics = false` を設定する。
- `programs.zed-editor.userSettings.telemetry.metrics = false` を設定する。
- `programs.zed-editor.userSettings.disable_ai = true` を設定する。
- `programs.zed-editor.userSettings.show_edit_predictions = false` を設定する。
- `programs.zed-editor.userSettings.features.edit_predictions.provider = "none"` を設定する。
- AI provider、account、API key、tokenは設定しない。

### Terminal

- `programs.zed-editor.userSettings.terminal.font_family = "Cica"` を設定する。
- `programs.zed-editor.userSettings.terminal.font_size = 14` を設定する。
- `programs.zed-editor.userSettings.terminal.shell = "system"` を設定する。
- `programs.zed-editor.userSettings.terminal.dock = "bottom"` を設定する。
- `programs.zed-editor.userSettings.terminal.working_directory = "current_project_directory"` を設定する。
- terminalのenvには秘密情報やmachine localな値を設定しない。

### Panels and Git

- `programs.zed-editor.userSettings.project_panel.git_status = true` を設定する。
- `programs.zed-editor.userSettings.git_panel.status_style = "icon"` を設定する。
- project panelとgit panelのdock、width、sort、open状態はZed既定に任せる。

### Extensions

- `programs.zed-editor.extensions` に `"nix"` を含める。
- `programs.zed-editor.extensions` に `"markdown-oxide"` を含める。
- `programs.zed-editor.extensions` に `"dockerfile"` を含める。
- `programs.zed-editor.extensions` に `"github-actions"` を含める。
- extensionのinstall、update、cache、local stateはZed本体に任せる。

### Languages, tasks, and debug

- `programs.zed-editor.userSettings.languages` は設定しない。
- `programs.zed-editor.userTasks` は設定しない。
- `programs.zed-editor.userDebug` は設定しない。
- project固有のtaskやdebug設定は各projectのZed設定で扱う。

## 非機能要件

- `pkgs.zed-editor` を評価しても、Home Manager activation packageのbuildでZed本体をbuildしない。
- Home Manager activationでZed設定ファイルをZedが更新できないread-only symlinkに置き換えない。
- Zed設定はHome Manager moduleのoptionとして表現する。
- raw JSONを手書きするためだけの `xdg.configFile."zed/settings.json"` は使わない。
- Zed本体のインストール状態に依存せずHome Manager buildが成功する。
- Zedが未インストールの環境でもHome Manager activationが成功する。
- 秘密情報、認証情報、token、session、cache、log、local stateをGit管理対象やNix storeに含めない。

## 検証

- ローカルで `nix flake check --show-trace` が成功すること。
- ローカルで `nix build --no-link --print-out-paths .#homeConfigurations.kakudo.activationPackage` が成功すること。
- 評価結果で `programs.zed-editor.enable = true` になっていること。
- 評価結果で `programs.zed-editor.package = null` になっていること。
- 評価結果で `home.packages` に `pkgs.zed-editor` が含まれないこと。
- 評価結果で `programs.zed-editor.userSettings.base_keymap = "VSCode"` になっていること。
- 評価結果で `programs.zed-editor.userSettings.vim_mode = false` になっていること。
- 評価結果で `programs.zed-editor.userSettings.buffer_font_family = "Cica"` になっていること。
- 評価結果で `programs.zed-editor.userSettings.ui_font_family = "Cica"` になっていること。
- 評価結果で `programs.zed-editor.userSettings.terminal.font_family = "Cica"` になっていること。
- 評価結果で `programs.zed-editor.userSettings.telemetry.diagnostics = false` になっていること。
- 評価結果で `programs.zed-editor.userSettings.telemetry.metrics = false` になっていること。
- 評価結果で `programs.zed-editor.userSettings.disable_ai = true` になっていること。
- 評価結果で `programs.zed-editor.userSettings.features.edit_predictions.provider = "none"` になっていること。
- 評価結果で `programs.zed-editor.extensions` に `"nix"`、`"markdown-oxide"`、`"dockerfile"`、`"github-actions"` が含まれること。
- 生成されるHome Manager filesにZedのsession、cache、log、local state、token、account情報が含まれないこと。
