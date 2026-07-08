```
決定→ /adr(Why)   実装(skill: csharp-layered-feature 自動ロード)
  → PostToolUse フックで dotnet format 検証(逆フィードバック)
  → 単位が固まったら /verify(build + test 緑)
  → /spec-sync(Web=OpenAPI 再生成)  → 意図が変われば REQ 更新 + 蒸留(distill-req)
  → /review + /cross-review(Codex)  → /done(DoDゲート)  → 人間が git commit
```
- 実装は **Plan モードでプラン承認 → フェーズ実装 → `/verify`**(プラン/タスクは一時物で実装後に破棄)。