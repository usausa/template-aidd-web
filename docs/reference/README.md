# reference(生成物・手編集禁止)

> ⚠ **このフォルダは生成物です。手で編集しないでください。**
> `.claude/settings.json` の `deny` により Claude からの `Edit`/`Write` はブロックされます。

現状仕様(What/How)は書いた瞬間から腐るので、**コードから生成**してドリフトを不能にする。

- `api/` … **Web API の OpenAPI**(`Microsoft.AspNetCore.OpenApi` / NSwag)。`openapi.json` を生成。
- `db/` … 任意。DB スキーマのダンプ(EF Core migrations script 等)。

生成は `/spec-sync` で行う(初期導入と CI でのドリフト検知は `sync-docs-from-code` スキル)。
コードのリファレンスサイト(DocFX 等)は作らない。振る舞いは**テスト(実行可能な仕様)**で担保する。

CI で `spec-sync` 後に `git diff --exit-code docs/reference` を実行すると、手編集・古い状態を物理的に禁止できる。
