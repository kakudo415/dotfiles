# Lock File Maintenance

## 背景

このリポジトリはNix FlakesとHome Managerでdotfilesを管理している。
`009-dependency-auto-update` でRenovateによる依存の自動更新を導入し、`flake.lock` の更新はinputごとの個別更新を主とし、`lockFileMaintenance` を週次で併用する構成にした。

Renovate App導入後の実際の動作では、inputごとの個別更新が1件も検出されなかった。
Dependency Dashboardは4つのroot inputをすべて `lock file @ <rev>` として検出しているが、更新候補としては現れない。
手動でRenovateを再実行しても結果は変わらなかった。

一方、`lockFileMaintenance` は正常に動作している。
最初の実行では7ノードが更新され、root inputsに加えて `bun2nix` や `llm-agents` 配下の `nixpkgs` などのtransitive nodeも追随した。
このpull requestはCI成功後に自動マージされ、自動更新の経路自体は設計どおり機能している。

Renovateの `nix` managerはbetaであり、branchを追従するinputに対する個別更新は現時点では機能しない。
`009-dependency-auto-update` が前提としていた主従が逆転しているため、実際に機能する `lockFileMaintenance` へ一本化する。

## 要求事項

- `flake.lock` の更新は `lockFileMaintenance` に一本化する。
- `lockFileMaintenance` は週次から日次へ変更する。
- inputごとの個別更新に対する設定は持たない。
- GitHub Actionsのaction versionの更新方針は変更しない。
- 自動マージとbranch protectionの方針は変更しない。
- READMEの記述を実際の動作に合わせる。

## 非対象

- Renovate以外の更新手段へ切り替えること。
- `nix` managerのbetaの挙動を設定で回避しようとすること。
- CI workflowを変更すること。
- `flake.nix` のinput定義を変更すること。

## 機能要件

### Flake input updates

- `lockFileMaintenance.schedule` を日次にする。日次のscheduleはtop levelの `schedule` と同じ時間帯とする。
- `nix` managerの有効化は維持する。無効にすると `lockFileMaintenance` も動作しない。
- `lockFileMaintenance` の自動マージは維持する。
- inputごとの個別更新に対するpackage ruleは置かない。

`lockFileMaintenance` はRenovateの既定で独自のscheduleを持つため、top levelの `schedule` を継承しない。
日次にするには `lockFileMaintenance` 側へ明示的に指定する必要がある。

個別更新を抑止する設定は置かない。
`nix` managerが個別更新に対応した時点で、`lockFileMaintenance` との併用方針をあらためて決める。

### Documentation

- READMEの `### Update` 節を、`flake.lock` が1本のpull requestで毎日更新される記述に改める。
- READMEからRenovateのonboarding pull requestに関する記述を削除する。

`renovate.json` を先にリポジトリへ入れた状態でRenovate Appをinstallしたため、Renovateは設定を検出してonboardingをskipした。
onboarding pull requestは作成されず、今後も作成されない。

## 非機能要件

- 変更はRenovate設定とREADMEの記述に限定する。
- `009-dependency-auto-update` のspecとADRは履歴として扱い、変更しない。
- 秘密情報、認証情報、token、session、cache、log、local stateをGit管理対象やNix storeに含めない。

## 検証

- ローカルで `nix flake check --show-trace` が成功すること。
- ローカルで `nix build --no-link --print-out-paths .#homeConfigurations.kakudo.activationPackage` が成功すること。
- ローカルで `renovate-config-validator --strict` が成功すること。
- Dependency Dashboardの `lockFileMaintenance` のscheduleが日次になっていること。
- `flake.lock` の更新pull requestが1日1本を超えないこと。
- 更新pull requestがCI成功後に自動マージされること。

## 参考資料

- Renovateの `lockFileMaintenance` は <https://docs.renovatebot.com/configuration-options/#lockfilemaintenance> を参照する。
- Renovateのnix managerは <https://docs.renovatebot.com/modules/manager/nix/> を参照する。
- 変更前の方針は `../009-dependency-auto-update/spec.md` と `../009-dependency-auto-update/adr/flake-lock-update-granularity.md` を参照する。
