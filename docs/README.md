# docs の地図と「寿命クラス」

ドキュメントは**寿命(腐りやすさ)で維持方針を分ける**。何を手で守り・生成し・追記だけするか — この表が人にも AI にも効く契約。
> README.md(入口)が置き換えられても、この契約と `AGENTS.md`(規律)は残る。**フレームワークの正はここと `AGENTS.md`**。

| 場所 | 種別 | 寿命 | 誰が維持 | 腐り対策 (延命方針) |
|---|---|---|---|---|
| `adr/` | **Why (決定理由)** | 不変 | 人 (AI 草案) | **追記のみ。過去 ADR は編集しない** |
| `architecture/` + `conventions.md` | **原則・方針** | 長 | 人 | 変更時のみ。機械化できる分は `.editorconfig` / analyzer へ。`conventions.md` は編集可 |
| `requirements/` | **意図 = spec (要求・何を/なぜ)** | 中 | 人 (AI 草案→承認) | 意図が変わる変更で更新。実装後に**蒸留** (復元できる情報は外す) |
| (実装プラン・タスク) | **一時物 (how)** | 破棄 | Plan モード + タスク | ファイル化しない。**実装完了後に破棄** |
| `reference/` | **What/How (現状仕様)** | 短 (生成) | **生成** | **手書き禁止**。Web=OpenAPI、振る舞い=テストが正 |
| `glossary.md` | **語彙** | 長 | 人 | 語彙・意味・英語名のみ。コード/DB で分かる情報は書かない |
| `review-checklist.md` | レビュー基準 | 中 | 人 | reviewer と Codex が共有 |
| `traceability/` | 索引 | 派生 | 生成/検査 | `/trace` |
| コード書式・品質 | What | — | **ツール** | `.editorconfig` + analyzer、**警告0** |
<!-- pm:readme-lifespan -->

## 📌 原則
- **Why は残す** (`adr/`)。**What/How は生成する** (`reference/`)。**書式は機械が守る** (analyzer)。→ 手で守る面積を最小化。
- **コードや DB で分かる情報は文書化しない・二重管理しない**。
- **SDD**: 実装をミラーする恒久設計書は持たない。意図=`REQ` / 決定=`ADR` / 原則=`architecture` / 現状=生成+テスト。
- **一時物は残さない**: 実装プラン / チェックリスト(タスク)は実装完了後に破棄。
- **退役**: 機能削除で `REQ`=`status: retired`・`ADR`=`superseded`。`/trace` が退役漏れを検出、`/done` が 0 を要求。

## 📌 ID 体系
- `REQ-NNNN` (要求) / `ADR-NNNN` (決定)。手書き文書は frontmatter (`id` / `status` / `related`)。

## 🔄 進め方
`guides/workflow.md` を参照。
