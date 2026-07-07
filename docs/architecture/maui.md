# アーキテクチャ (MVVM / レイヤ / UI) 【MAUI 固有】

> このファイルは **MAUI アーキテクチャ固有**。.NET 共通の規約は [`common/`](common/)、プロジェクト方針は [`conventions.md`](conventions.md) を参照。

## 🧱 レイヤ (依存は上→下のみ)

```
View (xaml) → ViewModel → Usecase → Service → (DB / Web API)
                  │           │
                  └── State ──┘        Domain (純粋ロジック・全層から利用可)
```

| レイヤ | 責務 |
|---|---|
| View (xaml/xaml.cs) | UI。コードビハインドにロジックを書かない。振る舞いは Behavior に分離 |
| ViewModel | Glue。Command で受け、実処理は Usecase/Service へ委譲 (Fat VM を避ける)。値反映は INotifyPropertyChanged / `NotificationValue<T>` |
| Usecase | 一連の流れ (通信→表示→保存 等)。Service に加え Dialog/State/Component を参照可。ステートレス singleton |
| Service | DB/通信のプリミティブ。上位を参照しない。授受は Model |
| Domain | 表示・IO に依存しない純粋ロジック。IO/Reflection を持ち込まない |
| State | アプリスコープの状態 (ログイン中ユーザ等)。オンメモリ + INotifyPropertyChanged |
| Models | POCO。用途別サブフォルダ (Api/Entity/View) |

## 📐 MVVM
- バインディングで処理を書く。コードビハインドにロジックを書かない。
- Behavior で振る舞いを共通化。Converter にロジックを書かず Domain へ委譲。Messenger で VM→View 要求。
- DI (Smart.Resolver 等) で View/VM/Service を解決。

## 🎨 UI / UX
- Style は `App.xaml` (`Resources/Styles`) に定義し、色・サイズ・マージンを要素へ個別指定しない (セマンティックなスタイル設計)。
- サイズは dpi を考慮した推奨値 (3, 6, 9, 12, 18, 24, 36, 48, 72 等) で統一。
- 表示変換は Converter、振る舞いは Behavior。ロジックは持ち込まない。
- アクセシビリティ (`SemanticProperties` 等) と多言語 (Localization) を考慮。
- ローディング / エラー / 空状態の表示を用意する。

## 🛑 異常系の具体 ([common/errors.md](common/errors.md) の実装)
- アプリ層の異常系は**戻り値**で通知する (例外でなく)。エラーコードと値はタプル / 専用型。

## 🪵 ログの具体 ([common/logging.md](common/logging.md) の実装)
- `ILogger` 経由。プロバイダは Logcat 出力 / ファイル出力 (MauiComponents 提供)。

## 💾 データの具体 ([common/data.md](common/data.md) の実装)
- 端末内 DB は SQLite (`Microsoft.Data.Sqlite`) + Micro-ORM。.NET 型 ⇔ SQLite 型は型ハンドラで変換 (Guid→TEXT, DateTime→INTEGER 等)。

## 🔐 セキュリティの具体 ([common/security.md](common/security.md) の実装)
- 秘匿値は `SecureStorage` / プラットフォームのキーストアに保存 (平文ファイルに置かない)。
- 権限 (カメラ・位置等) は `Permissions` で必要時に要求し、最小化する。
- 通信は証明書検証を有効に (必要に応じて証明書ピンニング)。
- 端末紛失を想定し、機微データをローカルに残しすぎない。
