# docs の地図と「寿命クラス」

このリポジトリのドキュメントは、**寿命 (腐りやすさ) で維持方針を分ける**。
何を手で守り、何を生成し、何を追記だけするか —— この表が人にも AI にも効く契約になる。

| 場所 | 種別 | 寿命 | 誰が維持 | 腐り対策 (延命方針) |
|---|---|---|---|---|
| `adr/` | **Why (決定理由)** | 不変 | 人 (AI 草案) | **追記のみ。過去 ADR は編集しない** |
| `architecture/` | **原則・規約** | 長 | 人 | 変更時のみ。機械強制できる分は `.editorconfig`/analyzer へ委譲。`conventions.md` はプロジェクト方針 (編集可) |
| `requirements/` | **意図 (要求)** | 中 | 人 (AI 草案→承認) | 意図が変わる変更で更新 |
| `design/` | **設計意図** | 中 | 人 (AI 草案→承認) | 同上。実装詳細は書かず**コードへ委譲** |
| `glossary.md` | **語彙 (ドメイン辞書)** | 長 | 人 | 語彙・意味・英語名のみ。コード/DB で分かる情報は書かない |
| `reference/` | **What/How (現状仕様)** | 短 (生成) | **生成** | **手書き禁止**。Web API は OpenAPI、振る舞いはテストが正 |
| `review-checklist.md` | レビュー基準 | 中 | 人 | reviewer と Codex が共有 |
| `traceability/` | 索引 | 派生 | 生成/検査 | `/trace` |
| コード書式・品質 | What | — | **ツール** | `.editorconfig` + analyzer、**警告0** |

## 原則
- **Why は残す** (`adr/`)。**What/How は生成する** (`reference/`)。**書式は機械が守る** (analyzer)。→ 手で守る面積を最小化。
- **コードや DB を見れば分かる情報は文書化しない・二重管理しない** (現状仕様=生成物+テスト、辞書/DES は語彙・意図のみ)。
- **SDD (仕様駆動)**: 実装を 1:1 でミラーする設計書は残さない。`DES`=意図、`ADR`=理由、現状=生成+テスト。
- `reference/**` は生成物。編集しない (`.claude/settings.json` の deny)。Web API の現状仕様は OpenAPI で生成する。

## ID 体系
- `REQ-NNNN` (要求) / `DES-NNNN` (設計意図) / `ADR-NNNN` (決定)。テスト・コードは `traceability/index.md` で対応づける。
- 手書き文書には frontmatter (`id` / `status` / `related`) を付け、`/trace` が機械検査できるようにする。

## 進め方
`guides/workflow.md` を参照 (決定→ `/adr`、実装→ build 逆ループ→ `/spec-sync`→ `/review`+`/cross-review`→ `/done`)。
