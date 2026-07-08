---
description: REQ/ADR/テストの有無から進捗ボードを更新する。feature 単位。
allowed-tools: Read, Grep, Glob, Write
---

`pm` サブエージェントに進捗集計を依頼する。

- `docs/requirements`・`docs/adr`・`tests/`・`docs/traceability/index.md` を走査。
- feature ごとに `REQ` / `ADR` / 実装 / テスト の有無を集計し、`docs/pm/progress.md` を更新。
- 方針は `docs/pm/README.md` が正。
