# はじめに (新規プロジェクトの立ち上げ)

1. このテンプレートを clone / コピー。ルート名・ソリューション名を自プロジェクトへ変更。
2. **アプリ形態を確定**: `pwsh ./setup.ps1 -Form maui|web`(採用しない形態の `docs/architecture/*.md` を削除)。
3. `AGENTS.md` の「スタック」節を採用形態に合わせて記入。
4. LINT / ビルド設定を確認: `.editorconfig` / `Directory.Build.props` / `Analyzers.ruleset` / `Settings.XamlStyler`(MAUI 用)は**全形態の superset**。実プロジェクトのテンプレで置き換えてよい。
5. ソースを配置(詳細は `src/README.md` / `tests/README.md`):
   - **Web**: `src/<App>/`(Blazor Server + minimal API)+ `<App>.AppHost`・`<App>.ServiceDefaults`(Aspire)。テスト `UnitTests`・`IntegrationTests`。OpenAPI 有効化(`AddOpenApi()` / `MapOpenApi()`)。
   - **MAUI**: `src/<App>/`(MVVM)。テスト `UnitTests`(+ 任意 `UITests`)。
   - ソリューションは `.slnx`(Solution Items に設定ファイルを束ねる)。
6. Claude Code 設定(`.claude/settings.json` の permissions / hooks)を確認。PowerShell フックに `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`。
   - **MCP**: `.mcp.json` に Microsoft Learn と NuGet MCP を同梱(初回は承認を求める。NuGet MCP は **.NET 10 SDK** の `dnx` が必要)。
   - **skill の追加**(任意)は `運用ガイド.md` を参照。
7. 最初の要求を `docs/requirements/` に書く(`/requirements` で草案生成も可)。

以降の開発の回し方は [workflow.md](workflow.md)。
