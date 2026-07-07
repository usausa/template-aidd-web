# tests (テストの配置先)

> 現時点でテストは未配置。ここは将来の配置先。テストは実装と同じ変更で書く (テスト=実行可能な仕様)。

## 想定構成

```
tests/
  <App>.UnitTests/          xUnit 単体テスト
  <App>.IntegrationTests/   WebApplicationFactory ベースの結合テスト (実際の DI / パイプラインで検証)
  <App>.E2ETests/           E2E テスト (Playwright)。任意
```

## メモ
- 受け入れ条件 (REQ の Given/When/Then) をテスト名に込める。例: `アップロード_サイズ超過で400を返す`。
- 結合テストは `Microsoft.AspNetCore.Mvc.Testing` の `WebApplicationFactory<Program>` を使う。
- ブラウザ経由の受け入れ確認が要る場合は `<App>.E2ETests`(Playwright)を任意で追加する (`WebApplicationFactory` の結合テストとは別軸)。
- テストプロジェクトも root の `Directory.Build.props` を継承する。
