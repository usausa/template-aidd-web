# プロジェクト方針 (編集可)

> このプロジェクト固有のコーディング / 設計方針。**チームで編集して育てる**ドキュメント。
> `.editorconfig` や analyzer で機械化できない「意味のルール」を置く。
> AI は `AGENTS.md` 経由でこれに従う。**機械強制ではない**ため、reviewer / Codex / 人のレビューで担保する。
> .NET 共通の不変原則は [`common/coding-principles.md`](common/coding-principles.md)、Web API 固有の規約は各アーキ固有ドキュメント。

## 📏 コーディング
- 定型 API の静的呼び出しは **BCL 型**で書く: `String.IsNullOrEmpty(x)` (`string.IsNullOrEmpty` としない)。
- 空文字などの**値**はキーワードで書く: `string.Empty` (`String.Empty` としない)。

## 📌 追記のしかた
- ここにプロジェクト固有の方針を追記していく ([`../review-checklist.md`](../review-checklist.md) の観点が本ファイルを参照するため、追記だけでレビュー対象になる)。
- 機械強制できるものは可能なら `.editorconfig` / `Analyzers.ruleset` へ寄せ、ここには「機械化できない意味ルール」を残す。

## 🧩 外部 skill / MCP との優先順位
- 外部スキル(例: maui-skills, dotnet/skills)や MCP(Microsoft Learn / NuGet 等)の助言は**参考・補完**。
- **本プロジェクトの `docs/architecture/*` と この `conventions.md` が常に優先**する。
- 外部の一般ベストプラクティスを採り入れるときは、本テンプレの方針と整合するか確認し、必要ならここへ明文化する。
