# 自動マージとbranch protectionの方針

## 背景

依存更新を毎日pull requestにすると、手動でマージし続ける運用は現実的でない。
一方で、CIを確認せずにマージすると壊れた更新がそのまま `main` へ入る。

Renovateの自動マージには2つの実行方式がある。
`platformAutomerge` を有効にするとpull request作成時にGitHubのauto-merge機能を有効化し、required status checksがgreenになった時点でGitHubがマージする。
無効にするとRenovateが次回実行時にstatus checkの結果を確認してマージする。

`main` には現在branch protectionが設定されていない。
GitHubにはrulesetをリポジトリ内のファイルから自動適用する標準機能がなく、設定手段はUI、JSONのimport、REST/GraphQL APIに限られる。

## 決定

自動マージはGitHubのauto-merge機能で実行する。
`platformAutomerge` はRenovate既定の `true` を維持し、リポジトリ設定の `Allow auto-merge` を有効にする。
自動マージの対象はflake inputの更新と、GitHub Actionsの `minor`、`patch`、`pin`、`digest` 更新とする。
`major` 更新は自動マージしない。

`main` のbranch protectionはGitHubのUIでrulesetとして設定し、`Flake check` と `Home Manager build` をrequired status checksに指定する。
required approvalsは `0` にする。
設定手順はREADMEに記述する。

required status checksを設定しないままauto-mergeを使うと、CIの結果を待たずにマージされる。
このためrulesetの設定はauto-mergeの前提条件になる。

## 検討した選択肢

### GitHubのauto-merge機能を使う

採用する。
required status checksがgreenになった時点でGitHubがマージするため、CI成功からマージまでの遅れが小さい。
リポジトリ設定で `Allow auto-merge` を有効化する操作が別途必要になる。

### Renovate自身にマージさせる

採用しない。
`Allow auto-merge` の設定を必要としないが、Renovateが次回実行時にstatus checkを確認してからマージするため、CIがgreenになってからマージされるまで実行間隔ぶんの遅れが出る。

### rulesetをJSONとしてリポジトリで管理する

採用しない。
設定内容をGit管理しレビューできるが、GitHubへの反映は手動コマンドのままで自動同期されない。
fileとGitHub側の状態がずれても検知できず、実態はUI設定と変わらない。

### Probot Settings Appで `.github/settings.yml` から同期する

採用しない。
repository設定を宣言的に管理できるが、Renovateに加えてもう1つサードパーティのGitHub Appへ依存することになる。

### branch protectionを設定しない

採用しない。
GitHubのauto-mergeはrequired status checksまたはrequired reviewsを持つbranchでしか有効化できないため、この選択肢ではauto-mergeを使えない。
`main` へのマージにゲートが無い状態も残る。

## 影響

- CIが成功した更新pull requestは人手を介さずマージされる。
- CIが失敗した更新pull requestはマージされず残り、Dependency Dashboard issueから追える。
- リポジトリ設定で `Allow auto-merge` を有効にする必要がある。
- `major` 更新は手動での確認とマージが必要になる。
- `main` へのマージにpull requestとCI成功が必須になる。この制約は人手で作るpull requestにも同じく適用される。
- ruleset自体はGit管理されないため、設定内容は仕様とREADMEの記述で担保する。
