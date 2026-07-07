---
description: reviewer サブエージェントを起動し、原則適合・意図との整合・トレーサビリティでレビューする。
allowed-tools: Read, Grep, Glob, Bash
---

`reviewer` サブエージェントに、現在の変更のレビューを依頼する。

観点:
1. `docs/architecture/` の原則(レイヤ責務、例外方針、async 規約 等)に反していないか
2. `REQ-` の**意図**との乖離(＝ドリフト)が無いか
3. 設計上の**決定**が ADR に記録されているか(未記録なら `/adr`)
4. 公開 API/型を変えたのに `docs/reference` が古くないか(→ `/spec-sync`)
5. `dotnet build` の警告がゼロか

指摘は Critical / Major / Minor に分類し、各指摘に対応する次アクション(コマンド)を併記させる。
