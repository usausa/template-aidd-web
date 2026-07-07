---
name: write-adr
description: Architecture Decision Record(ADR)の書き方・粒度・追記ルール。設計上の決定をした/迷ったとき、なぜその選択をしたかを残すために使う。
---

# ADR の書き方

- **1 ADR = 1 決定**。「なぜこの選択をし、何を捨てたか」を残す(現状仕様は書かない)。
- 置き場所: `docs/adr/NNNN-<kebab-title>.md`(採番は既存最大 +1)。`docs/adr/index.md` に 1 行追記。
- 構成(`_template.md` 準拠): 背景 / 決定 / 検討した代替案 / 結果(トレードオフ・影響)。
- **不変・追記のみ**。過去 ADR は編集しない。覆すときは新 ADR を起こし、旧 ADR の `status` を
  `superseded`、`superseded-by: ADR-NNNN` に更新する(status 行の更新のみ許容)。
- 粒度の目安: 「後から誰かが『なぜこうなってる？』と聞く」ものは ADR にする。
  例: 認証方式の選定、DI コンテナの選定、例外を戻り値にする方針、DB を SQLite にした理由。
- 迷い(trade-off があった判断)は、結論が平凡でも残す価値がある。

作成後、関連する `REQ` の `related` に ADR-ID を追記する。
