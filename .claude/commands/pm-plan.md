---
description: feature 単位 (1 feature ≒ 1 REQ) でイテレーション計画を作成・更新する。WBS/フェーズゲートは使わない。
argument-hint: [イテレーションの狙い]
allowed-tools: Read, Grep, Glob, Write
---

`pm` サブエージェントに、feature 単位のイテレーション計画を依頼する。

- `docs/requirements/` の `REQ` を backlog として、feature をイテレーションにグルーピングする (1 feature ≒ 1 REQ)。
- `docs/pm/iteration-plan.md` を更新する (feature 単位、状態付き)。
- **フェーズゲートや WBS-ID は導入しない**。1 feature = 1 まとまり (REQ→実装→テスト→レビュー)。
- 現状仕様や実装詳細は書かない (コード / 生成物が正)。
