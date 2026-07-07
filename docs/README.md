# docs の地図と「寿命クラス」

このリポジトリのドキュメントは、**寿命 (腐りやすさ) で維持方針を分ける**。
何を手で守り、何を生成し、何を追記だけするか —— この表が人にも AI にも効く契約になる。

| 場所 | 種別 | 寿命 | 誰が維持 | 腐り対策 (延命方針) |
|---|---|---|---|---|
| `adr/` | **Why (決定理由)** | 不変 | 人 (AI 草案) | **追記のみ。過去 ADR は編集しない** |
| `architecture/` | **原則・規約** | 長 | 人 | 変更時のみ。機械強制できる分は `.editorconfig`/analyzer へ委譲。`conventions.md` はプロジェクト方針 (編集可) |
| `requirements/` | **意図 = spec (要求・何を/なぜ)** | 中 | 人 (AI 草案→承認) | 意図が変わる変更で更新。実装後に**蒸留** (コード/テスト/ADR/architecture から復元できる情報は外す) |
| (実装プラン・タスク) | **一時物 (how)** | 破棄 | Plan モード + タスク | ファイル化しない。**実装完了後に破棄** (Spec Kit の plan/tasks 相当。ソースから復元できるものは残さない) |
| `glossary.md` | **語彙 (ドメイン辞書)** | 長 | 人 | 語彙・意味・英語名のみ。コード/DB で分かる情報は書かない |
| `reference/` | **What/How (現状仕様)** | 短 (生成) | **生成** | **手書き禁止**。Web API は OpenAPI、振る舞いはテストが正 |
| `review-checklist.md` | レビュー基準 | 中 | 人 | reviewer と Codex が共有 |
| `traceability/` | 索引 | 派生 | 生成/検査 | `/trace` |
| コード書式・品質 | What | — | **ツール** | `.editorconfig` + analyzer、**警告0** |
<!-- pm:readme-lifespan -->

## 📌 原則
- **Why は残す** (`adr/`)。**What/How は生成する** (`reference/`)。**書式は機械が守る** (analyzer)。→ 手で守る面積を最小化。
- **コードや DB を見れば分かる情報は文書化しない・二重管理しない** (現状仕様=生成物+テスト、辞書/REQ は語彙・意図のみ)。
- **一時物は残さない**: 実装プラン / チェックリスト (タスク) は Plan モードで作り、**実装完了後に破棄**する (Spec Kit の spec=`REQ` / plan / tasks のうち plan・tasks は非永続)。
- **退役させる**: 機能を削除したら `REQ` は `status: retired` (または削除)、`ADR` は不変なので `status: superseded/retired`。`/trace` が退役漏れ (参照先が消えた REQ) を検出し、`/done` が 0 を要求する。
- **SDD (仕様駆動)**: 実装を 1:1 でミラーする恒久設計書は持たない。意図=`REQ`、決定=`ADR`、原則=`architecture`、現状=生成+テスト。
- `reference/**` は生成物。編集しない (`.claude/settings.json` の deny)。Web API の現状仕様は OpenAPI で生成する。

## 📌 ID 体系
- `REQ-NNNN` (要求) / `ADR-NNNN` (決定)。テスト・コードは `traceability/index.md` で対応づける。
- 手書き文書には frontmatter (`id` / `status` / `related`) を付け、`/trace` が機械検査できるようにする。

## 🔄 進め方
`guides/workflow.md` を参照 (決定→ `/adr`、実装→ build 逆ループ→ `/spec-sync`→ `/review`+`/cross-review`→ `/done`)。
