# アーキテクチャ規約の地図

このプロジェクトの設計原則。**AI もこれに従って生成・レビューする**。迷ったらここ。
原則から外す判断は決定なので `/adr` で残す。

## 📁 分類

| 種別 | ファイル | 内容 |
|---|---|---|
| **アーキ固有 (MAUI)** | [`maui.md`](maui.md) | MVVM レイヤ、UI/UX、UI 側セキュリティ(MAUI 形態で採用) |
| **アーキ固有 (Web)** | [`api.md`](api.md) | レイヤ、minimal API、OpenAPI、API 命名・サーバ側セキュリティ(Web 形態で採用) |
| **アーキ固有 (Web)** | [`blazor.md`](blazor.md) | Blazor Server コンポーネント、UI/UX、UI 側セキュリティ(Web 形態で採用) |
| **プロジェクト方針 (編集可)** | [`conventions.md`](conventions.md) | analyzer で機械化できない、このPJ固有のコーディング / 設計方針 |
| **.NET 共通** | [`common/`](common/) | coding-principles / async / errors / logging / data / security(全形態共通) |

- **form 固有 doc は採用形態のものだけ残す**: `setup.ps1 -Form maui|web` が非採用の doc を削除する。この表の未採用行も削ってよい。
- **`common/`** = .NET 共通(全形態で同一内容)。
- **`conventions.md`** = このプロジェクトで編集して育てる方針(機械強制でなくレビューで担保)。
