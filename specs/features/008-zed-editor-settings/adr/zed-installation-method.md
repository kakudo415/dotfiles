# Zed本体の導入方法

## 背景

ZedはNixpkgsに `pkgs.zed-editor` として存在する。
現在のNixpkgs定義はRust source buildであり、macOSローカル環境で導入や更新を行うとbuild時間が大きくなる。

この機能の目的はZedのユーザー設定を先にHome Manager管理へ載せることであり、Zed本体のインストール方法を確定することではない。
Home Managerの `programs.zed-editor` moduleは `package = null` を指定できるため、Zed本体を導入せずに設定だけ管理できる。

## 決定

Zed本体はこの機能では導入しない。
Home Managerでは `programs.zed-editor.package = null` を明示し、`pkgs.zed-editor` を `home.packages` に追加しない。

Zed本体はHomebrew cask、手動インストール、その他の方法で別途導入できるものとして扱う。
どの導入方法を正式採用するかは、この機能の対象外とする。

## 検討した選択肢

### Nixで `pkgs.zed-editor` を導入する

採用しない。
Zed本体をsource buildするため、ローカル導入や更新の時間が大きくなる。

### Homebrew caskで導入する

この機能では採用も不採用も決めない。
公式binaryを使えるためbuild回避には有効だが、現時点ではHomebrew管理そのものをこのリポジトリに追加しない。

### 手動インストールする

この機能では採用も不採用も決めない。
最小手順で試せるが、再現性や更新管理は別途考える必要がある。

### 本体導入を保留し、設定だけHome Managerで管理する

採用する。
`programs.zed-editor.package = null` により、Zed本体の導入判断を後回しにしながら設定管理を先に整えられる。

## 影響

- Home Manager buildでZed本体のlocal source buildが発生しない。
- Zed本体が未インストールでもHome Manager buildとactivationは成功する。
- Zedを実際に使うには、別途Zed本体をインストールする必要がある。
- `defaultEditor`、`extraPackages`、`installRemoteServer` のようにZed packageを必要とする設定は使わない。
