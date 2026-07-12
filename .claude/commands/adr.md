---
description: 設計上の決定を ADR として docs/adr に追記する(過去の ADR は編集しない)。
argument-hint: [決定のタイトル]
allowed-tools: Read, Write, Glob, Bash
---

`docs/adr/` に新しい Architecture Decision Record を**追記**する。

手順:
1. `docs/adr/*.md` を Glob し、既存の最大連番 +1 を採番
2. `docs/adr/_template.md` を雛形に、`$ARGUMENTS` をタイトルとして `NNNN-<kebab-title>.md` を作成
3. 本文の「背景 / 決定 / 検討した代替案 / 結果(トレードオフ)」を、直近の会話・変更内容から具体的に埋める
4. `docs/adr/index.md` に 1 行追記
5. **過去の ADR は絶対に編集しない**(追記のみ)。決定を覆す場合は:
   - 新しい ADR を起こして決定を記述
   - 旧 ADR の `status` を `superseded` にし、`superseded-by` に新 ID を記す(これは status 行の更新のみ許容)
6. 生成した ADR の要点と、関連する SPEC があればその ID / ファイルを提示する
