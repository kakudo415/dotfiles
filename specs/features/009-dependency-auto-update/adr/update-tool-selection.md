# 依存更新ツールの選択

## 背景

このリポジトリの依存は `flake.lock` のflake inputsと、`.github/workflows` のGitHub Actions versionの2種類がある。
どちらも手動更新に依存しており、更新の頻度が一定しない。

自動更新した内容は既存CIの `Flake check` と `Home Manager build` で検証したい。
GitHubは既定の `GITHUB_TOKEN` で作成したpull requestに対してworkflowを起動しないため、botが作るpull requestでCIを走らせるには、別のtokenを用意するか、tokenを使わない仕組みを選ぶ必要がある。

flake inputsを更新するには実行環境に `nix` が必要になる。

## 決定

Renovateのhosted GitHub Appを使用する。
設定はリポジトリ直下の `renovate.json` に置く。

Renovateはflake inputsとGitHub Actions versionを同じ設定fileで扱える。
GitHub Appが作成するpull requestはworkflowを起動するため、CIの実行のためにtokenを追加しない。
Renovateの実行環境にはnixのinstallerが含まれており、`nix flake update` を実行できる。

## 検討した選択肢

### Renovateのhosted GitHub Appを使う

採用する。
flake inputsとGitHub Actions versionを1つの設定で扱え、リポジトリ側にworkflowもtokenも追加しない。
外部のGitHub Appへ依存し、Dependency Dashboard issueが1本増える。

### Renovateをself-hosted actionとして実行する

採用しない。
挙動をリポジトリ内に閉じ込められるが、pull requestの作成用にPATまたはGitHub App tokenを別途用意してsecretとして持つ必要がある。
CIがsecretを必要としないという既存の方針から外れる。

### DeterminateSystems/update-flake-lockを使う

採用しない。
flake inputsの更新だけを担うためGitHub Actions versionは別の仕組みが必要になる。
既定の `GITHUB_TOKEN` で作成したpull requestはworkflowを起動しないため、CIで検証するにはtokenの追加が必要になる。

### `nix flake update` とpull request作成actionを自前で組む

採用しない。
挙動は完全に制御できるが、スケジュール、更新の粒度、自動マージ、更新の保留といった仕組みをすべて自前で実装し保守することになる。

## 影響

- 依存更新の設定は `renovate.json` に集約される。
- flake inputsとGitHub Actions versionが同じスケジュールと同じ自動マージ方針で扱える。
- Renovateが作るpull requestで既存CIがそのまま実行される。
- リポジトリはRenovate GitHub Appのinstallに依存する。
- `renovate.json` はJSONのためコメントを持てず、設定の意図は仕様側に記述する。
