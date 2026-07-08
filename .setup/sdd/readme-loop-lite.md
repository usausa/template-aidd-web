```
/spec(箇条書き→仕様草案)→ 人がレビュー & 修正指示 → 承認
  → /plan(チェックリスト。大きければフェーズ分割)→ 承認
  → フェーズ実装(skill 自動ロード)+ チェック更新 + フェーズ末 /verify
  → PostToolUse フックで dotnet format 検証(逆フィードバック)
  → /spec-sync(Web=OpenAPI 再生成)→ /review + /cross-review(Codex)
  → /done(DoD + クローズ蒸留 → work/ の SPEC / PLAN を削除)→ 人間が git commit
```
- 仕様とプランは **`work/` の一時物**(git 管理外)。恒久に残るのは 決定=ADR / 用語=glossary / 受け入れ条件=テスト名。