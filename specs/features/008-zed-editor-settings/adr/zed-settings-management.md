# Zed設定ファイルの管理方法

## 背景

Zedのユーザー設定は主に `settings.json`、`keymap.json`、`tasks.json`、`debug.json` に保存される。
ZedのUI、command palette、keymap editorから行う変更も、これらのファイルへ反映される。

Home Managerには `programs.zed-editor` moduleがあり、Zed向けのsettings、keymaps、tasks、debug設定、extensions指定、mutable merge機能を提供している。
このmoduleを使うと、Zed設定をNix optionとして表現しつつ、Zedが更新するローカル設定ファイルとの共存もできる。

## 決定

Zed設定は `programs.zed-editor` moduleで管理する。
raw `xdg.configFile."zed/settings.json"` では管理しない。

`mutableUserSettings`、`mutableUserKeymaps`、`mutableUserTasks`、`mutableUserDebug` は既定値の `true` を維持する。
ローカルのZed設定ファイルはZedが更新できるmutable fileとして残し、Home Manager activationでNix管理設定をmergeする。
同じキーで競合した場合はNix管理設定を優先する。

## 検討した選択肢

### `xdg.configFile` でraw JSONを直接管理する

採用しない。
Home Manager moduleの型、Zed向けoption、extensions指定、mutable merge処理を活用できない。
設定ファイルの構造もNix module側の表現と重複する。

### Home Manager moduleでimmutable symlinkとして固定する

採用しない。
ZedはUIやkeymap editorから `settings.json` や `keymap.json` を更新する。
read-only symlinkとして固定すると、Zed側の設定変更が保存できない。

### Home Manager moduleのmutable mergeを使う

採用する。
Nix管理したい共通設定を再現可能にしながら、Zed本体が更新するローカル設定も維持できる。

## 影響

- Zed UIからの設定変更を維持しやすい。
- Home Manager activation時にNix管理設定がローカル設定へmergeされる。
- 競合する設定値はNix側が優先されるため、固定したい項目は再現性を保てる。
- `settings.json` などのローカルファイル全体はNix store由来のimmutable fileにはならない。
- Zedのsession、cache、log、token、account情報は管理対象に含めない。
