# CI

## 背景

このリポジトリはNix FlakesとHome Managerでdotfilesを管理している。
現在はローカルで `nix flake check` やHome Manager activation packageのbuildを実行して検証しているが、pull requestや `main` へのpush時に同等の検証を自動実行するCIがない。

Nix設定のformat崩れ、lint対象の問題、flake評価失敗、Home Manager構成のbuild失敗をCIで検出できるようにする。

## 要求事項

- GitHub ActionsでCIを実装する。
- Workflow fileは `.github/workflows/lint.yaml` とする。
- CIは `pull_request` と `main` branchへの `push` で実行する。
- CIはリポジトリ内容の読み取りのみを行い、secretやwrite権限を要求しない。
- 同一branchまたは同一pull requestで古い実行が残っている場合、新しい実行を優先して古い実行をcancelする。
- Nixのformat check、Nix lint、flake評価、Home Manager activation package buildを検証する。
- Nix Flakes inputsは `flake.lock` で固定する。
- Binary cache、Cachix cache連携、deployment、scheduled workflowはこの機能に含めない。

## 機能要件

### GitHub Actions

- Workflow名は `Lint` とする。
- Workflowは `.github/workflows/lint.yaml` に配置する。
- `permissions.contents = read` を設定する。
- `concurrency.group` はworkflow名とGit refを含む値にする。
- `concurrency.cancel-in-progress = true` を設定する。
- NixのinstallにはGitHub Actions上で利用可能なNix installer actionを使用する。
- Nix実行時は `nix-command` と `flakes` experimental featuresを有効にする。

### Format and lint job

- Job名は `format-lint` とする。
- Runnerは `aarch64-darwin` 向けのmacOS arm64 GitHub-hosted runnerを使用する。
- `nix flake check --show-trace` を実行する。
- このjobで次の検証を実行する。
  - Nix fileが `nixfmt-rfc-style` でformatされていること。
  - `statix check` が成功すること。
  - `deadnix --fail` が成功すること。
  - flake outputが評価できること。

### Home Manager build job

- Job名は `home-manager-build` とする。
- Runnerは `aarch64-darwin` のHome Manager構成をbuildできるmacOS arm64 GitHub-hosted runnerを使用する。
- `nix build --no-link --print-out-paths .#homeConfigurations.kakudo.activationPackage` を実行する。
- Buildはactivationを実行せず、activation packageの生成までを検証する。

### Flake outputs

- `treefmt-nix` をNix Flakes inputに追加する。
- `treefmt-nix.inputs.nixpkgs.follows = "nixpkgs"` を設定する。
- `formatter.aarch64-darwin` を定義する。
- Formatterは `nixfmt-rfc-style` を使用する。
- `checks.aarch64-darwin.format` を定義する。
- `checks.aarch64-darwin.statix` を定義する。
- `checks.aarch64-darwin.deadnix` を定義する。
- 既存の `homeConfigurations.kakudo` は `aarch64-darwin` 向けのまま維持する。

## 非機能要件

- CIはdotfilesのactivationやユーザー環境の変更を行わない。
- CIは秘密情報、秘密鍵、トークンを必要としない。
- Format/lint用のtoolingはflakeで管理し、ローカル実行とCI実行で同じtool versionを使用する。
- Workflowは主対象であるmacOS arm64 runnerでformat/lintとHome Manager buildを実行する。
- macOS runnerはGitHub-hosted runner documentationでarm64として提供されているlabelを使用する。

## 検証

- ローカルで `nix flake check` が成功すること。
- ローカルで `nix build --no-link --print-out-paths .#homeConfigurations.kakudo.activationPackage` が成功すること。
- CIで `format-lint` jobが成功すること。
- CIで `home-manager-build` jobが成功すること。
- `.nix` fileを `nixfmt-rfc-style` に反するformatへ変更した場合、format checkが失敗すること。
- 未使用bindingなどを追加した場合、`deadnix --fail` または `statix check` が失敗すること。
