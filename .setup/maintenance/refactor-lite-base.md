# lite 基層化リファクタ 方針書(実装ハンドオフ用)

> 位置づけ: 本書は**意図と改修方針**であり、実装手順(プラン)は含まない。実装エージェントは本書を入力に手順を起こす。
> 併読: 最終形の一覧は [command-map.md](command-map.md)。保守原則は [MAINTENANCE.md](MAINTENANCE.md)、確定方針は [decisions.md](decisions.md)、未決は [backlog.md](backlog.md)。
> 状態: 方針は人が承認済み(下記「確定した判断」)。**未実装**。

## 🎯 目的(一言)

現在 **full を基層 / lite を override** として持っている SDD 機構を反転し、**lite を基層・full/PM をその上の加算層**とする。あわせて命名を lite に統一し、setup オプションを排他選択にする。**実装の現状仕様(src/ のコード)は変えない** — テンプレの構造と命名の再整合が対象。

背景: lite は本テンプレの核(反ドリフト・蒸留)を最も純粋に体現する層。恒久化(full)と feature 管理(PM)は「必要な人だけが足す層」。「痩せた腐らない核が base、永続は opt-in」という構造にコードとドキュメントを一致させる。

## 📐 中心モデル: 3 層(加算・入れ子)

```
lite   ⊂   full            ⊂   full+pm
基層       +恒久 SPEC 層         +PM 層
```

```
基層 (lite)   : 1 機能を作るループ  /spec → /plan → /impl → /verify → /review → /done
                spec/plan は work/ の一時物。完了時に蒸留して消す(恒久の受け皿 = ADR / glossary / テスト名 / 生成物)
                随時: /adr(決定) / /reference(現状仕様の生成)
  + full      : ループの形は同じ。spec を恒久化(docs/spec/SPEC-NNNN)+ 蒸留して残す + /trace・traceability を追加
    + PM      : さらに上に「複数 feature の計画(/pm-plan)・進捗(/pm-status)」層。※full 前提(恒久 SPEC を台帳にするため)
```

- 各レベルは前を完全に含む chain(格子ではない)。
- **`/plan`(1 機能の中の実装計画) ≠ `/pm-plan`(機能をまたぐ計画)** — この 2 つの "計画" を混同しない。
- PM が full 前提な理由: PM の管理単位・データ源が恒久 SPEC 群 + traceability であり、lite はそれを持たない(spec を捨てる設計)ため。制約は層モデルから自然に導出される。

## 🔀 基層と差分の正確な定義

### 基層(= 現 lite)の振る舞い
- `/spec <箇条書き>` → `spec` エージェント → `work/SPEC-<topic>.md`(一時・gitignore)。様式は目的/背景・スコープ・受け入れ条件(GWT)・非機能・未決事項。
- `/plan` → `work/PLAN-<topic>.md`(チェックリスト・フェーズ分割)。
- `/impl` → 実装(`csharp-layered-feature` skill)。
- `/verify` → build(警告0)+ 静的解析 + test + 自己修正。
- `/review`(+ `/review-cross`)→ レビュー。
- `/done` → DoD ゲート + `spec-close`(蒸留して **work/ を削除**)+ コミットコマンド提示。
- 随時: `/adr`(`adr-guide` skill)/ `/reference`。
- **無いもの**: 恒久 spec、`/trace`、`docs/traceability/`。

### full 差分(-Sdd full が変える/足す)
| 観点 | 基層 (lite) | full |
|---|---|---|
| spec 置き場 | `work/SPEC-<topic>.md`(一時) | `docs/spec/SPEC-NNNN-<title>.md`(恒久・採番) |
| 完了時 | `spec-close`= 蒸留して **削除** | `spec-close`= 蒸留して **残す**(distill-in-place)+ status 更新 |
| トレーサビリティ | なし | **`/trace` + `docs/traceability/`**(SPEC↔ADR↔test↔code) |
| plan | `work/PLAN-*`(一時) | 同じ(**full でも PLAN は一時**) |

> 本質は一点: 基層は spec を「足場(蒸留後に消す)」、full は spec を「恒久の軽量意図(蒸留後も残す)」として扱う。

### PM 差分(-PM 相当・full 前提)
- `/pm-plan`(`pm` エージェント)→ `docs/pm/iteration-plan.md`(恒久 SPEC 群を backlog に、feature 単位のイテレーション計画)。
- `/pm-status` → `docs/pm/progress.md`(SPEC/ADR/test/traceability を走査し feature 単位で進捗集計)。
- 方針は `docs/pm/README.md`。

## 🏷️ 命名の統一(lite に合わせる)

| 現 full | 現 lite | 統一後 | 種別 | 備考 |
|---|---|---|---|---|
| `/requirements` | `/spec` | **`/spec`** | command | lite に統一 |
| `requirements` | `spec` | **`spec`** | agent | 〃 |
| `REQ-NNNN` | `SPEC-<topic>` | **`SPEC`**(full=`SPEC-NNNN`恒久 / lite=`SPEC-<topic>`一時) | 成果物 | D1 |
| `docs/requirements/` | (`work/`) | **`docs/spec/`**(full)/ `work/`(lite) | dir | D1 |
| `distill-req` | `spec-close` | **`spec-close`**(挙動を層差分に: full=残す / lite=消す) | skill | D3。単一名 |
| `/spec-sync` | `/spec-sync` | **`/reference`** | command | `/spec` との混同回避(現状仕様=生成物) |
| `write-adr` | `write-adr` | **`adr-guide`** | skill | 接頭辞ルール |
| `/cross-review` | `/cross-review` | **`/review-cross`** | command | 接頭辞ルール |
| (自然文実装) | (自然文実装) | **`/impl`**(新設・基層) | command | モデル切替点(下記) |
| (native Plan) | `/plan` | **`/plan`**(基層・両モード) | command | full も明示コマンド化 |
| `/verify` `/review` `/done` `/adr` `/trace` | 同 | **維持** | command | `/verify` は維持(D6) |

### 命名原則(新規・実装時に decisions.md へ追記)
1. **接頭辞グルーピング**: コマンドとその補助 skill/agent は共通接頭辞。`spec-*`(spec, spec-close)/ `adr-*`(adr, adr-guide)/ `review-*`(review, review-cross)。横断 skill(`git-commit` 等・特定コマンドの所有物でない)は対象外。
2. **taxonomy**: コマンドは「ループ定常段(/spec /plan /impl /verify /review /done)」と「オンデマンド(/adr /reference /trace)」に二分。オンデマンドは『機能開発中にトリガが立ったら随時』であり、`/adr` を "プロジェクト全体方針限定" とはしない(機能実装中の決定も記録する)。

## ⚙️ setup オプションの再設計(排他選択)

`lite / full / full+pm` は 1 本の順序付き軸(入れ子)であり、直交する 2 フラグではない。現状の `-Sdd full|lite` + `-PM` スイッチは 1 軸を 2 フラグに分解し、無効な組み合わせ(lite+pm)を表現できてしまうため実行時 `throw` で弾いている。**単一の排他パラメータにして、無効値を構文的に表現不能にする**(throw も撤去)。

```powershell
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('maui','web','desktop','worker')]
    [string]$Form,                                   # アプリ形態 = 独立した直交軸(そのまま)

    # SDD レベル = 単一の排他選択。 lite ⊂ full ⊂ full+pm。既定 full。
    # ※ 'full' / 'full-pm' は仮称(再考)。パラメータ名 -Sdd も PM を含むため要再考。
    [ValidateSet('lite','full','full-pm')]
    [string]$Sdd = 'full'
)
# → -PM スイッチと `if ($PM -and $Sdd -eq 'lite'){ throw }` は撤去
```

選択値が「いくつ層を足すか」に 1:1 対応する(加算機構と一致):

| 選択 | 加算する層 |
|---|---|
| `lite` | なし(基層のまま) |
| `full` | 恒久化層(恒久 SPEC / distill-in-place / trace) |
| `full-pm` | 恒久化層 + PM 層 |

留意点: この単一 enum が最適なのは SDD 軸が線形(PM が唯一の追加要素で full 必須)な現設計だから。将来 lite/full に独立して付く別モディファイアが増えると格子になり再検討。`-Form` は直交軸なので別パラメータのまま。

## 🔧 setup 機構の反転(実装の中核)

- **現状**: repo の base ファイル = **full**。`.setup/sdd/lite/` が lite 用に「full 固有を削除 + ファイル差し替え」。`.setup/pm/` が PM を挿入。既定 full。
- **目標**: repo の base ファイル = **lite**。`.setup/sdd/full/`(新設)が full 層を**加算**(spec コマンド/エージェントの恒久版で上書き・`spec-close` の残す版で上書き・`/trace` 追加・`docs/spec/_template.md` と `docs/traceability/` 追加・workflow/done の full 版で上書き)。`.setup/pm/` が PM 層を加算(full の上)。**既定は full 据え置き**(no-flag で full 層を適用)。
- マーカー(`<!-- sdd:xxx -->` 9 個)の扱い: base 本文 = lite 版をインラインにし、full はマーカー置換 or ファイル上書きで加算。マーカー方式かファイル上書きかは項目ごとに実装エージェントが選ぶ。

## 🤖 /impl とモデル方針(確認済み)

- スラッシュコマンドは frontmatter `model:` 対応。**override はそのターン限り**(次プロンプトでセッションモデルに戻る)。サブエージェントも `model:` 対応だが、実装はフック反復が要るためメインループで動く `/impl` コマンドが適。
- 配布物の既定: **`/impl` は `model:` を置かず(=セッションモデル継承)、"安価モデルに切替える例をコメントで併記"** の opt-in。実装品質を既定で落とさない。
- `/impl` 本文: `work/PLAN-*` と spec(lite=`work/SPEC-*` / full=`docs/spec/SPEC-*`)を読み、`csharp-layered-feature` + `docs/architecture/` の責務でフェーズ実装、警告ゼロ、PLAN チェック更新、フェーズ末に `/verify`。

## ✅ 確定した判断(人が承認済み)

| # | 論点 | 決定 |
|---|---|---|
| D1 | full の恒久 spec 名 | **`SPEC-NNNN` に統一**(`docs/spec/`)。REQ 語彙は廃止 |
| D2 | setup 機構 | **lite 基層 + full/PM 加算**。既定モードは **full 据え置き**(挙動不変) |
| D3 | close skill 名 | **`spec-close` 単一名**(挙動を層差分に) |
| D4 | `/spec-sync` 改名先 | **`/reference`** |
| D5 | 接頭辞ルール範囲 | **`adr-guide` + `/review-cross`** を実施 |
| D6 | `/verify` | **維持** |
| — | setup オプション | **単一排他 enum**(lite/full/full-pm)。値名・パラメータ名は TBD |

## 🗺️ 影響インベントリ(実装の触り先。実装前に自分で再 grep すること)

**機構ファイル(最重要)**
- `setup.ps1` — SDD 分岐の反転 + 排他 enum 化 + PM 加算。
- `.setup/sdd/` — マーカー変種 9 種 ×`{full,lite}`(agents-dod / agents-intent / lifespan-spec / principle-id / principle-retire / readme-loop / readme-start / review-intent / skill-flow)+ 現 `lite/` ミラー。→ base=lite 化に伴い `full/` ステージへ再編。
- `.setup/pm/` — 挿入 4 種(agents / guide-claude / readme-lifespan / workflow-iteration)。
- `.setup/maintenance/test-setup.ps1` — 全シナリオ(4 form × 3 レベル)で新名称の存在/不在アサートへ更新。実装後 **ALL PASS が完了条件**。`decisions.md`(方針追記)・`design.md`(構造説明)も更新。

**配布物の参照(改名の追随先)**
- `docs/guides/workflow.md`(参照多数・lite 版が基層になる)、`README.md`、`AGENTS.md`(+ sdd/pm マーカー)、`docs/README.md`(寿命クラス表)、`docs/review-checklist.md`、`docs/reference/README.md`、`docs/architecture/api.md`、`docs/adr/0001`、`docs/glossary.md`(REQ→SPEC の英語名)。
- `.claude/commands` / `agents` / `skills` の各本文、`docs/spec/_template.md`(旧 requirements)、`docs/traceability/`、`docs/pm/`(REQ→SPEC 参照)。
- grep 目安: `requirements|spec-sync|write-adr` = **29 ファイル / 56 箇所**。**D1(SPEC 統一)により `REQ` 全走査**を追加。

## 🚧 実装エージェントが守る制約

- `MAINTENANCE.md` 原則: **二重管理しない / 機械が守るルールは文書化しない / superset + 確定時削除 / 命名原則 / 文体**(日本語・ASCII と括弧は半角・中黒 `・` は全角・`§` 不使用・h2 絵文字は docs 系のみ)。
- **完了条件 = `pwsh .setup/maintenance/test-setup.ps1` が ALL PASS**。マーカー/保守ブロック残存 0 も含む。
- **AI はコミットしない**(`/done` はコマンド提示のみ)。
- 常時ロードは `CLAUDE.md`(= `@AGENTS.md`)のみ。description 等の固定費を増やさない。
- 現状仕様(src/ のコード)は変更対象外。

## 🔭 スコープ外の検討事項(将来・[backlog.md](backlog.md) に記録)

- **ceremony**: Spec Kit の `/clarify`・`/analyze`・独立 `/tasks` 相当を lite が畳んでいる件(複雑機能での前捌きの薄さ)。
- **`/done` の蒸留の安全網**: 「テスト/ADR/glossary のどれにも載らず消える意図はないか」の確認を close に足す案。

本改修では扱わない。詳細は backlog.md の該当項目。

## 📤 実装エージェントへの依頼方法

本書と [command-map.md](command-map.md) だけで自己完結する(前提知識なしの別セッションでも実行可能)。**強モデル(Opus 等)の Claude Code セッションを原本リポジトリで開き、2 フェーズ**で依頼する。プラン→承認→実装のゲートは本テンプレ自身の思想(承認まで実装しない)に一致する。

- **推奨**: 専用の対話セッション(人の承認ゲートと回帰の反復が要るため、一発の subagent より対話が向く)。プラン作成フェーズは Plan モード推奨。
- 参照専用: 本書・command-map.md・MAINTENANCE.md・decisions.md。

### フェーズ A: 実装プラン作成(承認まで実装しない)

```text
あなたはこの template-aidd 原本の保守担当です。まず .setup/maintenance/MAINTENANCE.md を読み、
続いて .setup/maintenance/refactor-lite-base.md(方針)と command-map.md(最終形)を読んでください。

これらに従い「lite 基層化リファクタ」の実装プラン(チェックリスト)を作成してください。まだ実装はしない。
プランは次を満たすこと:
1. 作業を段階に分解: 命名統一 / setup 機構の反転(lite 基層 + full・PM 加算)/ 排他 enum 化 /
   .setup/sdd の full ステージ再編 / 配布物の参照追随 / test-setup.ps1 更新 / decisions.md 追記。
2. 各段階に完了条件を付ける。
3. 影響ファイルは自分で再 grep して列挙する(方針書のインベントリは目安)。
確定済みの判断(D1〜D6・setup 排他 enum)は方針書のとおり。制約は方針書「実装エージェントが守る制約」。
最終の完了条件は pwsh .setup/maintenance/test-setup.ps1 が ALL PASS。
プランを提示して人の承認を待つこと。
```

### フェーズ B: 実装(プラン承認後)

```text
承認済みプランに沿って段階実装してください。各段階の後に pwsh .setup/maintenance/test-setup.ps1 で回帰し、
赤があればその場で直す(最終 ALL PASS が完了条件)。旧名称・旧記述は残さない。
新しい命名原則と setup 排他 enum を decisions.md に追記し、実装後に backlog.md の該当項目を整理する。
コミットはしない — Conventional Commits のコミットコマンドを人に提示するに留める(git-commit skill 準拠)。
文体は日本語・ASCII と括弧は半角・§ 不使用。
```

### 補足
- test-setup.ps1 は現状 form × SDD × PM のシナリオ。**排他 enum(lite/full/full-pm)× 4 form** へ再構成し、新コマンド/エージェント/スキル名の存在・不在アサートを追加すること(この更新自体もプランの一段)。
- 値名(`full`/`full-pm`)・パラメータ名(`-Sdd`)が未確定。実装前に確定させるか、暫定名で進めて後で一括置換できるようプランに含める。
