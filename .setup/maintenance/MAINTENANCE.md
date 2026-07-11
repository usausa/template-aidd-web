# テンプレート保守ガイド(原本のみ・最初に読む)

> このディレクトリは **template-aidd 原本の保守者(人 / AI)向け**。利用者には配布されない(`setup.ps1` が `.setup/` ごと削除する)。
> テンプレの利用方法は root の `README.md`、利用時の規約は `AGENTS.md`(いずれも配布物)。ここは**テンプレ自体を変更する**ときの正。

## 🎯 このテンプレートの本質(一言)

**「GitHub Spec Kit の SDD フロー(spec → plan → tasks → implement)を .NET × Claude Code に特化し、plan / tasks を一時物にして、ADR + 生成現状仕様 + 機械強制でドリフト対策を厚くしたテンプレート」**(解説と外部比較は [design.md](design.md))

## 📌 保守の原則(これに反する変更をしない)

1. **二重管理しない**: 規範は 1 箇所の「正」+ 参照に一本化する。複製・個名列挙は腐る(列挙が腐った実績あり)。意図的に許容する重複の基準は [decisions.md](decisions.md)。
2. **機械が守るものは文書化しない**: analyzer(SA1309 等)/ permission deny / hook が強制するルールを文書に書かない。
3. **superset + 確定時削除**: オプション(form / SDD / PM)は原本に全部置き、`setup.ps1` が非採用分の削除とマーカー解決で確定する。原本に「利用者向けでない情報」を置くときは、setup で消える場所(この `.setup/` か `template-dev` ブロック)に置く。
4. **命名原則**: 系名(web / desktop / mvvm)= 系の全般、技術名(api / blazor / wpf / winui)= 技術固有。プラットフォーム固有 skill は `<platform>-xxx`(例: `blazor-playwright`)。
5. **文体**: 日本語。ASCII 記号・括弧は半角(中黒 `・` は全角のまま)、`§` 不使用、冗長・自明な括弧補足を書かない。h2 絵文字は docs 系のみ(`.claude/` と AGENTS / CLAUDE には付けない)。

## 🗺️ リポジトリの仕掛け(どこを触ると何が起きるか)

| 仕掛け | 場所 | 内容 |
|---|---|---|
| form 削除 | `setup.ps1` の `$formDocs` | 系ごとの採用 doc リスト。**winui.md は登録済み**(ファイルを置くだけで採用される) |
| Web 固有 skill | `setup.ps1` | `blazor-playwright` は web 以外の form で削除 |
| SDD マーカー | `<!-- sdd:xxx -->` × 9(AGENTS / docs/README / README / review-checklist / csharp-layered-feature) | `.setup/sdd/xxx-{full,lite}.md` の変種を挿入(常にどちらかが入る) |
| SDD lite 差分 | `.setup/sdd/lite/`(リポジトリのミラーツリー) | lite 時に配置。`workflow.md` / `done.md` は**上書き** |
| PM マーカー | `<!-- pm:xxx -->` × 4 | `-PM` で `.setup/pm/` から挿入、既定は除去 |
| 保守ブロック | `<!-- template-dev:start/end -->`(AGENTS.md / README.md) | setup が節ごと除去(原本専用の記述はここに書く) |
| 常時ロード | `CLAUDE.md` = `@AGENTS.md` の 1 行のみ | 固有メモを足さない(AGENTS が正) |

## 🔄 保守のフロー

1. 変更する(上の原則に従う)。**決定を伴うなら [decisions.md](decisions.md) に追記**、保留・未決は [backlog.md](backlog.md) へ(確定したら backlog から消して decisions へ)。
2. **検証**: `pwsh .setup/maintenance/test-setup.ps1` — form × SDD × PM の全シナリオで、マーカー解決・ファイル配置/削除・保守痕跡ゼロを確認する。**ALL PASS が完了条件**。
3. マーカー・オプション・form を増やしたら、`test-setup.ps1` にチェックを追加する。
4. コミットは Conventional Commits(`.claude/skills/git-commit/` 準拠)。commit / push は人が実行。

## 📁 このディレクトリの構成

- `MAINTENANCE.md` — 本ファイル(入口)
- [decisions.md](decisions.md) — 確定した設計方針(テンプレ開発の決定記録・追記式)
- [backlog.md](backlog.md) — 未決の検討事項(TODO)
- [design.md](design.md) — 設計解説(構造と Claude 機構・GitHub Spec Kit 比較)
- [test-setup.ps1](test-setup.ps1) — `setup.ps1` の回帰テスト
- [refactor-lite-base.md](refactor-lite-base.md) — lite 基層化リファクタの方針書(実装ハンドオフ用・未実装)
- [command-map.md](command-map.md) — lite 基層化後のコマンド/エージェント/スキル最終形リファレンス
