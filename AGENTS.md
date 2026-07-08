# プロジェクト規約 (Claude / Codex 共通)

> このファイルが唯一の「正」。`CLAUDE.md` はこれを import するだけ。**短く保ち**、詳細は `docs/` と `.claude/skills/` に置く。

## スタック
- 言語: C# / .NET (`LangVersion=preview`, `Nullable=enable`, `ImplicitUsings=enable`)
- 種別: `<アプリ形態を記入 (MAUI / ASP.NET Core Web / Desktop(WPF) / worker / library 等)>` ← `setup.ps1` で採用した形態に合わせる
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
- 文書の寿命・置き場は `docs/README.md` の寿命クラス表が正。
- **決定(Why)** → `docs/adr/` に**追記** (過去 ADR は編集しない)。`/adr`
- **現状仕様(What/How)** → 手で書かない。**Web なら OpenAPI 生成** (`/spec-sync`)、振る舞いは**テスト**が正。**コードや DB で分かる情報は文書化しない (二重管理しない)**。
<!-- sdd:agents-intent -->
- 命名は `docs/glossary.md` の英語名に合わせる。
- `docs/reference/**` は生成物。**手編集しない**。
<!-- pm:agents -->

## レビュー
- レビュー観点は `docs/review-checklist.md` (Claude `/review` と Codex `/cross-review` が共有)。

## 完了条件 (DoD)
<!-- sdd:agents-dod -->
- Claude は完了前に `/done` で上記を一括点検する。
- Git 操作 (commit / push) は**人間が実行** (AI はコマンドを提示するのみ)。提示するコミット文 / ブランチ名は `git-commit` skill(Conventional Commits)に従う。

## 記述
- ドキュメント・コメントは日本語。
