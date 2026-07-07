# プロジェクト規約 (Claude / Codex 共通)

> このファイルが唯一の「正」。`CLAUDE.md` はこれを import するだけ。**短く保ち**、詳細は `docs/` と `.claude/skills/` に置く。

## スタック
- 言語: C# / .NET 10 (`LangVersion=preview`, `Nullable=enable`, `ImplicitUsings=enable`)
- 種別: ASP.NET Core Web (**Blazor Server + minimal API**)。ログは Serilog
- ソースは `src/`、テストは `tests/` (.NET Aspire の AppHost / ServiceDefaults も `src/` 配下)
- 環境固有値 (接続先・キー) はリポジトリに実値を置かず、`appsettings` + ユーザーシークレット / 環境変数で扱う

## コーディング
- 書式は `.editorconfig` に従う (唯一の正)。メンバ変数に `_` プレフィックスを付けない。
- **ビルド警告ゼロが完了条件**。抑制は適用前に確認 (局所 `#pragma`、恒久 `GlobalSuppressions.cs`)。
- アーキテクチャは `docs/architecture/` に従う (`api.md`・`blazor.md` + `common/*`)。
- **プロジェクト固有方針は `docs/architecture/conventions.md`** (例: 静的呼び出しは `String.IsNullOrEmpty`、値は `string.Empty`、API は `XxxRequest`/`YyyResponse`・top-level 配列を返さない)。機械化できないためレビューで担保。
- セキュリティは `common/security.md` + `api.md`・`blazor.md`。
- 外部 skill / MCP(Microsoft Learn / NuGet 等)の助言より、本プロジェクトの `docs/architecture/*` と `conventions.md` を優先する。

## ドキュメント規律 (動態・最重要)
- **決定(Why)** → `docs/adr/` に**追記** (過去 ADR は編集しない)。`/adr`
- **現状仕様(What/How)** → 手で書かない。**Web API は OpenAPI を生成** (`/spec-sync`)、振る舞いは**テスト**が正。**コードや DB で分かる情報は文書化しない (二重管理しない)**。
- **意図(要求/設計)** が変わる → 同じ変更内で `docs/requirements/`・`docs/design/` を更新。**SDD (仕様駆動): 実装を 1:1 でミラーする設計書は残さない (`DES`=意図)**。
- 命名は `docs/glossary.md` の英語名に合わせる。
- `docs/reference/**` は生成物。**手編集しない**。

## レビュー
- レビュー観点は `docs/review-checklist.md` (Claude `/review` と Codex `/cross-review` が共有)。

## 完了条件 (DoD)
- `dotnet build` 警告ゼロ / 影響 docs 更新 / 決定は ADR / `/trace` 整合 / レビュー観点を満たす。
- Git 操作 (commit / push) は**人間が実行** (AI はコマンドを提示するのみ)。提示するコミット文 / ブランチ名は `git-commit` skill(Conventional Commits)に従う。

## 記述
- ドキュメント・コメントは日本語。
