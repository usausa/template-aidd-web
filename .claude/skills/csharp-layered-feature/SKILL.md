---
name: csharp-layered-feature
description: このプロジェクトの層構成(docs/architecture/ 参照)に沿って C# の機能を追加する手順。機能・画面・API・サービス追加のときに使う。
---

# C# レイヤ機能追加の手順(汎用)

> レイヤの具体(名前・責務)は `docs/architecture/`(採用形態の doc + `common/*`)に従う。ここは順序と原則のみ。

<!-- sdd:skill-flow -->
2. **下位から上位へ**: Domain(純粋ロジック・IO を持たない)→ Service(DB/通信のプリミティブ)→ Usecase/Application(一連の流れ)→ 上位(ViewModel / Endpoint / Component)。**上位は薄く、下位へ委譲**。
3. **テスト**(`tests/`): 受け入れ条件を xUnit で。**テスト名を仕様として書く**(例: `ログイン_失敗5回でロックされる`)。
4. **XML doc コメント**: 公開 API に付ける。
5. **仕上げ**: `/verify`(build + test 緑)→ 現状仕様が変わったら `/spec-sync`(Web=OpenAPI)→ `/review` → `/done`。

## アンチパターン(`docs/architecture` 準拠)
- 上位層(ViewModel / Endpoint / Component)にロジックを書く(→ 下位へ委譲)
- アプリ層の異常系を例外で通知する(→ 戻り値 / `IResult` + ProblemDetails)
- `Task.Wait()` / `Task.Result` / 不要な `Task.Run()`(→ `await`)
- SQL で表示用加工(→ 上位で加工)
