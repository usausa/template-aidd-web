---
name: sync-docs-from-code
description: 現状仕様(What/How)をコードから生成する手順。Web API は OpenAPI、DB はスキーマダンプ。公開APIや型を変えた後、docs/reference を最新化するときに使う。
---

# コードから docs/reference を生成する

**原則: 現状仕様は手で書かない。ズレようがない生成物にする。**

## Web API → OpenAPI(`Microsoft.AspNetCore.OpenApi`, .NET 10 内蔵)
- アプリに登録:
  ```csharp
  builder.Services.AddOpenApi();
  app.MapOpenApi();            // 開発時に /openapi/v1.json を公開
  ```
- `docs/reference/api/openapi.json` へ出力する方法(いずれか):
  - **ビルド時生成**: `Microsoft.Extensions.ApiDescription.Server` を参照し
    `<OpenApiGenerateDocumentsOnBuild>true</OpenApiGenerateDocumentsOnBuild>` を設定 → build 時に JSON 生成 → `docs/reference/api/` へコピー。
  - **起動して取得**: アプリ起動後 `curl http://localhost:<port>/openapi/v1.json -o docs/reference/api/openapi.json`。
  - **NSwag CLI**: `nswag run`。
- CI では生成後に `git diff --exit-code docs/reference` を実行し、差分が出たら失敗させる(ドリフト検知)。

## DB → スキーマ(任意)
- EF Core: `dotnet ef migrations script -o docs/reference/db/schema.sql`

## 共通
- 生成後 `git diff --stat docs/reference` で差分を要約。差分＝コードと仕様がズレていた証拠。関連 `REQ`/テストの更新要否を報告する。
- `docs/reference/**` は手編集しない(settings.json の deny 済み)。
