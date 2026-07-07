# レビュー観点 (Claude reviewer / Codex 共有)

> このファイルは `reviewer` サブエージェント (Claude) と、別途 codex で行うクロスレビューが**共有する単一の基準**。
> 変更のたびにこれらの観点で確認し、指摘は Critical / Major / Minor に分類する。

## 📐 1. アーキ・原則
- `docs/architecture/` の原則に反していないか (レイヤ責務、上位層は薄く下位へ委譲、async 規約)。
- .NET 共通原則 (`common/*`) に反していないか。

## 📏 2. プロジェクト方針
- `docs/architecture/conventions.md` の方針に沿っているか。
  - 例: 静的呼び出しは BCL 型 (`String.IsNullOrEmpty`)、値はキーワード (`string.Empty`)。
  - 例 (Web): リクエスト / レスポンスは `XxxRequest` / `YyyResponse`、トップレベルで配列を返さない。

## 📌 3. 意図との整合と蒸留
- 実装が `REQ` の意図に一致しているか (不一致は「ドリフト」として報告)。
- **REQ が蒸留されているか**: コード / テスト / ADR / architecture から**復元できる情報が REQ に残っていない**か (残っていれば `distill-req` で外すよう指摘)。

## 🧭 4. 決定の記録
- 設計上の決定をしたのに ADR が無い、を検出する (→ `/adr`)。

## 📌 5. 現状仕様の鮮度
- 公開 API / 型 / スキーマを変えたのに `docs/reference` (OpenAPI 等) が古い (→ `/spec-sync`)。

## 🔐 6. セキュリティ
- `common/security.md` とアーキ固有のセキュリティ観点 (秘匿情報・入力検証・認証認可・通信) を満たすか。

## 🔤 7. 用語
- 命名が `docs/glossary.md` の英語名と一致しているか。

## 📌 8. 品質
- **`build` + `test` が緑か** (`/verify`)。警告ゼロ。テストが受け入れ条件を表現しているか。
