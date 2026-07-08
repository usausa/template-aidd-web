---
description: feature 単位 (1 feature ≒ 1 REQ) でイテレーション計画を作成・更新する。WBS/フェーズゲートは使わない。
argument-hint: [イテレーションの狙い]
allowed-tools: Read, Grep, Glob, Write
---

`pm` サブエージェントに、feature 単位のイテレーション計画を依頼する。

- `docs/requirements/` の `REQ` を backlog として、`docs/pm/iteration-plan.md` を更新する (feature 単位、状態付き)。
- 方針 (1 feature ≒ 1 REQ・WBS / フェーズゲート不使用・現状仕様は書かない) は `docs/pm/README.md` が正。
