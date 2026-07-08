# プロジェクト規約 (Claude / Codex 共通)

> このファイルが唯一の「正」。`CLAUDE.md` はこれを import するだけ。**短く保ち**、詳細は `docs/` と `.claude/skills/` に置く。

## スタック
- 言語: C# / .NET (`LangVersion=preview`, `Nullable=enable`, `ImplicitUsings=enable`)
- 種別: `<アプリ形態を記入 (MAUI / ASP.NET Core Web / worker / library 等)>` ← `setup.ps1` で採用した形態に合わせる
- ソースは `src/`、テストは `tests/`
- 環境固有値 (接続先・キー) はリポジトリに実値を置かない (`SecureStorage` / user-secrets / 環境変数)

## コーディング
- 書式・命名は `.editorconfig` + analyzer が正 (機械が守るルールは文書化しない)。
- **ビルド警告ゼロ + テスト緑が完了条件**: `dotnet build`(警告0)+ `dotnet test`(Claude は `/verify`)。警告抑制は適用前に確認。
- アーキテクチャは `docs/architecture/` に従う (採用形態の doc + `common/*`)。
- **プロジェクト固有方針は `docs/architecture/conventions.md`**(機械化できずレビューで担保)。
- セキュリティは `common/security.md` + 採用形態の architecture doc。
- 外部 skill / MCP(Microsoft Learn / NuGet 等)の助言より、本プロジェクトの `docs/architecture/*` と `conventions.md` を優先する。

## ドキュメント規律 (動態・最重要)
- 文書の寿命・置き場は `docs/README.md` の寿命クラス表が正 (まずそこを見る)。
- **決定(Why)** → `docs/adr/` に**追記** (過去 ADR は編集しない)。`/adr`
- **現状仕様(What/How)** → 手で書かない。**Web なら OpenAPI 生成** (`/spec-sync`)、振る舞いは**テスト**が正。**コードや DB で分かる情報は文書化しない (二重管理しない)**。
- **意図(要求 = spec)** が変わる → 同じ変更内で `docs/requirements/` を更新。**SDD: 実装をミラーする恒久設計書は持たない。意図=`REQ` / 決定=`ADR` / 原則=`architecture` / 現状=生成+テスト**。
- **REQ は蒸留して残す**: コード / テスト / ADR / architecture から復元できる情報は REQ に置かない。実装後に `distill-req` で機械的に外す (意図の更新と同じ変更内)。
- 命名は `docs/glossary.md` の英語名に合わせる。
- `docs/reference/**` は生成物。**手編集しない**。
<!-- pm:agents -->

## レビュー
- レビュー観点は `docs/review-checklist.md` (Claude `/review` と Codex `/cross-review` が共有)。

## 完了条件 (DoD)
- **build + test 緑**(`dotnet build` + `dotnet test`。Claude は `/verify`)/ 影響 docs 更新 + REQ 蒸留 / 決定は ADR / `/trace` 整合(退役漏れ含む)/ レビュー観点を満たす。
- Claude は完了前に `/done` で上記を一括点検 (未達なら列挙して停止)。
- Git 操作 (commit / push) は**人間が実行** (AI はコマンドを提示するのみ)。提示するコミット文 / ブランチ名は `git-commit` skill(Conventional Commits)に従う。

## 記述
- ドキュメント・コメントは日本語。
