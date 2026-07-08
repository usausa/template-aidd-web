# C# × Claude Code AI駆動開発テンプレート(.NET 汎用)

C# / .NET × Claude Code の AI駆動開発テンプレート(1 本の汎用テンプレ)。
**この README だけで、始め方・使い方・ドキュメント群の意図がわかる**ようにしてある。
> 注: この README は**テンプレ使用者向けの入口**で、Claude に自動ロードされない。**導入後は自プロジェクトの README に置き換え/削除してよい** — フレームワークの正は `AGENTS.md`(規律)・`docs/README.md`(寿命・永続化の契約)・`docs/guides/workflow.md`(手順)にあり、この README には依存しない。

## 🎯 3原則
- **レーンを固定**: C# + Claude 前提。標準は具体的で深い。
- **不変と可変を分離**: engine(`.claude` / `docs`)/ 生成物(`docs/reference`)/ 環境固有値 を分ける。
- **ドキュメントを腐らせない**: Why=ADR、What/How=生成・テスト、書式=analyzer、更新は hooks / `/done` で変更に埋め込む。

## 🚀 始め方(セットアップ)
1. clone / コピーし、ルート名・ソリューション名を自プロジェクトへ。
2. **形態を確定**: `pwsh ./setup.ps1 -Form maui|web [-PM]`
   - `-Form` = アプリ形態(非採用の `docs/architecture/*.md` を削除)。
   - `-PM` = プロジェクト管理(feature 単位の計画/進捗)を有効化(未指定なら PM ファイルとマーカーを削除)。
3. `AGENTS.md` の「スタック」節を採用形態に記入。
4. LINT / ビルド設定(`.editorconfig` / `Directory.Build.props` / `Analyzers.ruleset` / `Settings.XamlStyler`[MAUI])は**全形態の superset**。実プロジェクトのテンプレで置換してよい。
5. ソースを配置(詳細 `src/README.md` / `tests/README.md`):
   - **Web**: `src/<App>/`(Blazor + minimal API)+ Aspire(`AppHost` / `ServiceDefaults`)。テスト `UnitTests` / `IntegrationTests`。OpenAPI 有効化。
   - **MAUI**: `src/<App>/`(MVVM)。テスト `UnitTests`(+ 任意 `UITests`)。
6. Claude Code 設定(`.claude/settings.json`)確認。PowerShell フックに `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`。MCP(`.mcp.json` = Microsoft Learn + NuGet)は初回承認、NuGet は .NET 10 SDK の `dnx` が必要。
7. 最初の要求を `/requirements <一言>` で作る。

## 🔄 使い方(開発ループ)
```
決定→ /adr(Why)   実装(skill: csharp-layered-feature 自動ロード)
  → PostToolUse フックで dotnet format 検証(逆フィードバック)
  → 単位が固まったら /verify(build + test 緑)
  → /spec-sync(Web=OpenAPI 再生成)  → 意図が変われば REQ 更新 + 蒸留(distill-req)
  → /review + /cross-review(Codex)  → /done(DoDゲート)  → 人間が git commit
```
- **各段の具体プロンプト**(コピペ可)は `docs/guides/workflow.md`。
- 実装は **Plan モードでプラン承認 → フェーズ実装 → `/verify`**(プラン/タスクは一時物で実装後に破棄)。

### コマンド早見表
| コマンド | いつ | 主体 |
|---|---|---|
| `/requirements <一言>` | 要求 REQ 草案 | 人 |
| `/adr <決定>` | 決定・トレードオフを残す | 人 |
| (自然文で依頼) | 実装(skill 自動ロード) | 人→AI |
| `/verify` | build + test(自己修正) | 人 / AI |
| `/spec-sync` | Web API/型/DB を変えた(OpenAPI 再生成) | 人 |
| `/review` / `/cross-review` | レビュー(Claude / Codex) | 人 |
| `/trace` | ID 整合・決定漏れ・退役候補の検査 | 人 |
| `/done` | DoD ゲート(build+test緑・蒸留・退役・ADR・trace・review) | 人 |

## 📁 ファイルの役割(`.claude` = 動かす仕組み)
| ファイル | 主体 | 役割 |
|---|---|---|
| `settings.json` | 自動 | 権限・hooks。`reference/**` の手編集を deny |
| `hooks/dotnet-verify.ps1` | 自動(編集後) | `dotnet format` 検証 → 差分を返す(逆ループ) |
| `hooks/source-normalize.ps1` | 自動(編集後) | ソースを **UTF-8(BOM 無し)+ CRLF** に正規化(`.editorconfig` と別に編集時強制) |
| `hooks/done-check.ps1` | 自動(応答終了) | DoD リマインド |
| `commands/*.md` | **人** `/...` | requirements / adr / verify / spec-sync / review / cross-review / trace / done |
| `agents/*.md` | 委譲 | requirements(要求草案)/ reviewer / doc-sync(reference 生成) |
| `skills/*/SKILL.md` | 自動ロード | csharp-layered-feature / write-adr / sync-docs-from-code / git-commit / distill-req |
<!-- pm:guide-claude -->

## 🗂️ 寿命・永続化(何を編集し・生成し・残すか)
- **決定=`docs/adr/`(追記のみ・不変)/ 原則=`docs/architecture/`(編集)/ 意図=`docs/requirements/`(REQ、編集 + 実装後に蒸留)/ 現状仕様=`docs/reference/`(生成・手書き禁止、Web=OpenAPI・振る舞い=テスト)/ 実装プラン=一時物(破棄)/ 索引=`docs/traceability/`(`/trace`)**。
- **退役**: 機能削除で `REQ`=`status: retired`・`ADR`=`superseded`(`/trace` が検出、`/done` が 0 要求)。ID は `REQ-NNNN` / `ADR-NNNN`。
- **正の一覧(寿命クラス表)は `docs/README.md`、AI 常時ルールは `AGENTS.md`**(この README は入口なので置き換え可)。

## 🧭 このドキュメント群の意図
- **SDD(Spec Kit 風)**: 仕様(= REQ)を中心に AI が実装。**実装を 1:1 でミラーする恒久設計書は持たない**(DES 廃止)。意図=REQ / 決定=ADR / 原則=architecture / 現状=生成+テスト。
- **腐らせない**: コード/DB で分かる情報は文書化しない(二重管理しない)。現状仕様は生成、意図は蒸留、一時物は破棄、不要は退役。
- **担保**: `/verify` → `distill-req` → `/trace` → `/done` の機械チェック連鎖(ゲート)。バイパス不能なハード強制(Husky.Net / CI)は `template-aidd-検討事項.md` 参照。
- **コンテキスト**: 常時ロード(固定費)は `CLAUDE.md`(+ `AGENTS.md`)/ 各 skill の description / MCP ツール定義のみ。この README・`docs/**`・commands/skills 本文は**オンデマンド**。

## 🧩 MCP と skill(拡張)
- **MCP(同梱)**: `.mcp.json` に Microsoft Learn(docs grounding)+ NuGet(パッケージ・脆弱性)。ツール定義は固定費なので **Learn / NuGet に絞る**(可視ツール ~50 上限)。
- **skill**: 標準 5(csharp-layered-feature / write-adr / sync-docs-from-code / git-commit / distill-req)。追加は MAUI=`davidortinau/maui-skills`、Web=公式 `dotnet/skills` 等を**選別**(plugin か vendor-copy)。**`conventions.md` が常に優先**。description は固定費なので入れすぎない。

## 🔗 リンク
- 各段の具体プロンプト: `docs/guides/workflow.md`
- アーキ原則: `docs/architecture/`(採用形態の doc + `common/*`)
- PM(`setup.ps1 -PM` で有効化)を使うと `/pm-plan`・`/pm-status` で feature の計画・進捗
