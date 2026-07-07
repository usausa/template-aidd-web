# C# × Claude Code AI駆動開発テンプレート(.NET 汎用)

C# / .NET × Claude Code の AI駆動開発テンプレート(1 本の汎用テンプレ)。
**アプリ形態(MAUI / ASP.NET Core Web 等)は `setup.ps1 -Form maui|web` で確定**する。

## 📌 3原則
- **レーンを固定**: C# + Claude 前提。標準は具体的で深い。
- **不変と可変を分離**: engine(`.claude` / `docs`) / 生成物(`docs/reference`) / 環境固有値 を分ける。
- **ドキュメントを腐らせない**: Why=ADR、What/How=生成・テスト、書式=analyzer、更新は hooks / `/done` で変更に埋め込む。

## 📌 セットアップ / 形態選択
- `pwsh ./setup.ps1 -Form maui|web` で採用形態を確定(非採用の architecture doc を削除)。詳細は `docs/guides/getting-started.md`。
- form 固有 doc: `docs/architecture/{maui.md | api.md + blazor.md}`。共通は `docs/architecture/common/*`。

## 📌 スタック / LINT
- C# / .NET(MAUI または ASP.NET Core Web など)。
- `.editorconfig` + `Directory.Build.props`(`EnforceCodeStyleInBuild` / `WarningsAsErrors` / `AnalysisMode=All`)+ `Analyzers.ruleset`(全形態の superset)+ `Settings.XamlStyler`(MAUI 用)。
- 方針は「**ルールは緩めても警告はゼロ**」。LINT / ビルド設定は実プロジェクトのテンプレで置き換えてよい。

## 📁 構成(予定)
- `src/` … アプリ本体(Web は + .NET Aspire)。詳細は `src/README.md`。
- `tests/` … 単体・結合(+ 任意 E2E / UI)テスト。詳細は `tests/README.md`。
- ※ 現時点でソースは未配置。`src/`・`tests/` は将来の配置先。

## 🔄 使い方
- 立ち上げ・開発フロー・各ファイルの役割は、ルート直下の **`運用ガイド.md`** を参照。
- 文書の寿命方針は `docs/README.md`、各段階で打つ具体プロンプトは `docs/guides/workflow.md`。
