# flake.lock更新の粒度

## 背景

Renovateのnix managerは `flake.lock` に対して2つの更新方法を持つ。

1つはinput個別更新で、`flake.lock` のroot inputを1つずつdependencyとして扱う。
このリポジトリでは `nixpkgs`、`home-manager`、`llm-agents`、`treefmt-nix` が対象になる。
いずれもbranchを追従しているため更新種別は `digest` になり、更新は `nix flake update <input名>` で実行される。
pull request本文にinputごとの新旧revが出る。

もう1つは `lockFileMaintenance` で、lockの内容を解釈せずに `nix flake update` を実行し、`flake.lock` に差分が出たらpull requestにする。
更新種別は1つだけで、pull requestは常に1本になる。

nix managerはroot inputに現れないtransitive nodeをdependencyとして扱わない。
Nixはinput flakeの `flake.lock` を参照せずroot flakeのlockを解決し直すため、`llm-agents` が `inputs.nixpkgs.follows` を設定していない現状では、`llm-agents` 配下の `nixpkgs` や `bun2nix` は `llm-agents` 自体が動かなくても更新されうる。

## 決定

日次はinput個別更新を使い、group設定は行わない。
これに加えて `lockFileMaintenance` を週次で有効にする。

日常的な更新はinputごとのpull requestとして扱い、どのinputがどこからどこへ動いたかをpull requestから読めるようにする。
週次の `lockFileMaintenance` は、input個別更新が扱わないtransitive nodeを回収する役割を持つ。

## 検討した選択肢

### input個別更新のみを使う

採用しない。
どのinputが動いたかは読みやすいが、transitive nodeが更新されないまま固定される。

### input個別更新と週次の `lockFileMaintenance` を併用する

採用する。
日々の更新はinput単位で読め、transitive nodeも週1回で追随する。
同じ日に両方のpull requestが立った場合、内容が重複しうる。

### input個別更新をgroup設定で1本のpull requestにまとめる

採用しない。
pull requestは1本に減るが、transitive nodeの取り残しは解消しない。

### `lockFileMaintenance` のみを使う

採用しない。
transitive nodeまで追随し設定も単純だが、更新内容が1つのpull requestに集約されるため、何が動いたかは `flake.lock` のdiffを読むことになる。
input単位で方針を変えるpackage ruleも書けない。

## 影響

- 平常時は1日あたり最大4本の更新pull requestが立つ。
- pull request titleに更新されたinput名が入る。
- input単位のpackage ruleを後から追加できる。
- 週1回、`nix flake update` 相当のpull requestが追加で立つ。
- 日次更新と週次 `lockFileMaintenance` が同じ日に重なると、同じ内容の更新が2本のpull requestに現れる。先にマージされた側に対してRenovateがrebaseし、差分が無くなったpull requestは自動でcloseされる。
- transitive nodeの更新は最大で1週間遅れる。
