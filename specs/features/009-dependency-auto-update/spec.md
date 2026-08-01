# Dependency Auto Update

## 背景

このリポジトリはNix FlakesとHome Managerでdotfilesを管理している。
Flake inputsは `flake.lock` で固定しているが、更新は手動の `nix flake update` だけに依存しており、思い出したときにしか実行されていない。

`nixpkgs` は `nixpkgs-unstable` を追従しているため上流は毎日動くが、`flake.lock` は実際には数コミットしか更新されておらず、ローカル環境と上流の差が開きやすい。
GitHub Actionsで参照しているaction versionも同じく手動更新に依存している。

依存更新を毎日自動でpull requestにし、既存CIのflake checkとHome Manager activation package buildが成功したものだけを自動でmainへ取り込む。
これにより、まとめて更新したときに壊れる範囲が広がる問題を避け、壊れた場合の原因を1日分の差分に限定する。

自動更新は毎日CIを実行するため、CIの実行時間がそのまま運用コストになる。
Nix storeをGitHub Actions cacheに保存し、毎回のフル評価とフルbuildを避ける。

## 要求事項

- 依存更新はRenovateのhosted GitHub Appで実行する。
- Renovateの設定はリポジトリ直下の `renovate.json` に置く。
- 更新対象は `flake.lock` のflake inputsと、GitHub Actionsのaction versionとする。
- 更新は毎日日本時間の早朝に実行する。
- `flake.lock` のflake inputsはinputごとに個別のpull requestで更新する。
- root inputに現れないtransitive nodeを取り残さないため、`nix flake update` 相当の更新を週次で併用する。
- 既存CIの `Flake check` と `Home Manager build` が成功したpull requestだけを自動マージする。
- major更新は自動マージせず、手動で確認してからマージする。
- 自動マージの前提として `main` にbranch protectionを設定する。
- CIはNix storeをGitHub Actions cacheに保存し、次回の実行で再利用する。
- CIはsecretを必要としない。
- Renovateが更新を保留した場合や更新に失敗した場合を追えるようにする。

## 非対象

- Cachixのようにauth tokenを必要とするbinary cacheを導入すること。
- `flake.nix` の `home-manager` release branchを次のreleaseへ追従させること。
- `pkgs/cica.nix` のfont versionとhashを自動更新すること。
- GitHubのrepository設定やrulesetをリポジトリ内のファイルから自動適用すること。
- `llm-agents` に `inputs.nixpkgs.follows` を設定してinput graphを変更すること。
- 自動マージ後にローカル環境へ自動でactivationすること。
- CIの実行環境をmacOS arm64以外へ広げること。

## 機能要件

### Renovate configuration

- Renovate hosted GitHub Appをこのリポジトリにinstallする。
- 設定fileはリポジトリ直下の `renovate.json` とする。
- `extends` に `config:recommended` を指定する。
- `timezone` に `Asia/Tokyo` を設定する。
- `schedule` は毎日4時台から7時台の間に実行される値にする。
- `semanticCommits` に `enabled` を設定する。
- `dependencyDashboard` に `true` を設定する。
- `prConcurrentLimit` と `prHourlyLimit` は設定せず、Renovateの既定値を使用する。
- `renovate.json` はJSONのためコメントを持たない。設定の意図はこの仕様に記述する。

`semanticCommits` の既定値は `auto` で、直近のcommit履歴からsemantic commitの採否を判定する。
このリポジトリのcommit履歴はsemantic commitではないため、`enabled` を明示しない限りsemantic commitのpull request titleにならない。

### Flake input updates

- `nix` managerを有効化する。
- `flake.lock` のroot inputはinputごとに個別のpull requestとして更新する。
- 複数のinputを1つのpull requestへまとめるgroup設定は行わない。
- `lockFileMaintenance` を有効化し、週次のscheduleを設定する。
- `lockFileMaintenance` のscheduleは日次更新と同じ時間帯の、週1日とする。

Renovateの `nix` managerは既定で無効のため、明示的な有効化が必要になる。

`nix` managerは `flake.lock` のroot inputだけをdependencyとして扱い、transitive nodeを更新対象にしない。
Nixはinput flakeの `flake.lock` を参照せずroot flakeのlockを解決し直すため、`llm-agents` 配下の `nixpkgs` や `bun2nix` は `llm-agents` 自体が動かなくても更新されうる。
週次の `lockFileMaintenance` はこの取り残しを回収する役割を持つ。

日次のinput更新と週次の `lockFileMaintenance` が同じ日に実行された場合、両者は同じ内容の更新を含みうる。
先にマージされた側の結果に対してRenovateがrebaseし、差分が無くなったpull requestは自動でcloseされる。

### GitHub Actions updates

- `github-actions` managerで `.github/workflows` 配下のaction versionを更新する。
- action versionはRenovateの既定どおりtag参照のまま更新し、commit SHAへのpinには変更しない。

### Automerge

- flake input更新のpull requestは自動マージする。
- GitHub Actions更新のpull requestは `minor`、`patch`、`pin`、`digest` を自動マージする。
- `major` 更新は自動マージしない。
- `platformAutomerge` はRenovate既定の `true` を維持し、GitHubのauto-merge機能でマージする。

flake inputはいずれもbranchを追従しており、更新種別は `digest` になる。

Renovateはpull request作成時にGitHubのauto-mergeを有効化し、required status checksがgreenになった時点でGitHubがマージする。
Renovateの次回実行を待たないため、CI成功からマージまでの遅れが小さい。
required status checksを設定せずにauto-mergeを使うと、CIの結果を待たずにマージされる。

### Branch protection

- リポジトリ設定の `Allow auto-merge` を有効にする。
- `main` にrulesetを作成する。
- `Require a pull request before merging` を有効にする。
- required approvalsは `0` にする。
- `Require status checks to pass` を有効にし、`Flake check` と `Home Manager build` をrequired status checksに指定する。
- required reviewersは設定しない。
- rulesetはGitHubのUIで設定し、リポジトリ内のファイルとしては管理しない。
- ruleset設定の手順はREADMEに記述する。

required approvalsを1以上にすると、Renovateが自身のpull requestをマージできなくなる。

### CI cache

- `.github/workflows/checks.yaml` の両jobで、Nix storeをGitHub Actions cacheに保存および復元する。
- Cacheの操作には `nix-community/cache-nix-action` を使用する。
- Cache stepはNixのinstall stepの直後に置く。
- Cache keyにはjobと `flake.lock` のhashを含める。
- Cacheの復元はjobまでのkey prefixで一致させる。
- Cacheの保存前にNix storeをgarbage collectionし、macOS向けのstore size上限を指定する。
- 古いcache entryをpurgeし、purge対象は同じkey prefixに限定する。
- 現在のprimary keyのcache entryはpurgeしない。

Jobごとにkeyを分けるのは、`Flake check` と `Home Manager build` でNix storeの内容が異なるためである。

GitHub Actions cacheはbranchごとにscopeが分かれ、pull requestの実行は自身のscopeへ保存しつつdefault branchのscopeから復元できる。
Cacheのpurgeも実行中のrefのscopeに限定されるため、pull requestの実行が `main` のcache entryを削除することはない。

`nix flake check` と `nix build --no-link` はGC rootを残さないため、store size上限をbuild後のstore sizeより小さくすると、直前にbuildした成果物から回収される。
Store size上限はbuild後のstore sizeに対して余裕を持たせ、成果物がcacheに残るようにする。

GitHub Actions cacheはリポジトリあたり10GBの上限を持つため、store size上限は2つのjobが同時に保存しても上限へ届かない値にする。

### CI permissions

- `permissions.contents` は `read` のまま維持する。
- Cache entryのpurgeに必要な `permissions.actions = write` を追加する。
- CIはsecretを参照しない。

`002-ci` ではCIがwrite権限を要求しない方針としていたが、cache entryのpurgeにはGitHub Actions cache APIへの書き込みが必要になる。
追加する権限はcacheの操作に限られ、リポジトリ内容への書き込み権限は与えない。

### Documentation

- READMEの `### Update` 節に、`flake.lock` がRenovateによって毎日更新され、CIが成功すると自動マージされることを記述する。
- 手動の `nix flake update` は即時に更新したい場合の手段として残すことを記述する。
- Renovate GitHub Appをこのリポジトリにinstallする手順を記述する。
- リポジトリ設定で `Allow auto-merge` を有効にする手順を記述する。
- `main` のrulesetを設定する手順を記述する。

## 非機能要件

- 自動更新はdotfilesのactivationやユーザー環境の変更を行わない。
- 自動更新とCIは秘密情報、秘密鍵、tokenを必要としない。
- Cacheが存在しない場合やcacheの復元に失敗した場合でも、CIはfull buildで成功する。
- Pull requestの実行によるcache purgeが `main` のcache entryを削除しない。
- Renovateが更新を保留した場合や更新に失敗した場合は、Dependency Dashboard issueから確認できる。
- CIの実行環境は主対象であるmacOS arm64 runnerのまま維持する。
- 変更はRenovate設定、CIのcacheと権限、READMEの記述に限定する。
- 秘密情報、認証情報、token、session、cache、log、local stateをGit管理対象やNix storeに含めない。

## 検証

- ローカルで `nix flake check --show-trace` が成功すること。
- ローカルで `nix build --no-link --print-out-paths .#homeConfigurations.kakudo.activationPackage` が成功すること。
- ローカルで `renovate-config-validator renovate.json` が成功すること。
- CIで `Flake check` jobが成功すること。
- CIで `Home Manager build` jobが成功すること。
- CIのlogでNix storeのcacheが保存されること。
- `flake.lock` を変更しない2回目のCI実行で、Nix storeのcacheが復元されること。
- Renovate App install後にDependency Dashboard issueが作成されること。
- `flake.lock` のinputごとに個別のpull requestが作成されること。
- Pull request titleが `chore(deps):` で始まるsemantic commit形式になること。
- 更新pull requestで `Flake check` と `Home Manager build` の両方が実行されること。
- CIが成功した更新pull requestが自動マージされること。
- CIが失敗した更新pull requestが自動マージされないこと。
- `major` 更新のpull requestが自動マージされないこと。
- 週次の `lockFileMaintenance` pull requestが作成されること。

## 参考資料

- Renovateの設定項目は <https://docs.renovatebot.com/configuration-options/> を参照する。
- Renovateのnix managerは <https://docs.renovatebot.com/modules/manager/nix/> を参照する。
- Renovateのgithub-actions managerは <https://docs.renovatebot.com/modules/manager/github-actions/> を参照する。
- Nix storeのcacheには <https://github.com/nix-community/cache-nix-action> を使用する。
- GitHubのrulesetは <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository> を参照する。
- 更新ツールの選定は `adr/update-tool-selection.md` を参照する。
- `flake.lock` 更新の粒度は `adr/flake-lock-update-granularity.md` を参照する。
- 自動マージとbranch protectionの方針は `adr/automerge-and-branch-protection.md` を参照する。
