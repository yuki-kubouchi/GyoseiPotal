# 行政ポータル (Gyosei Potal) - 業務管理システム

[![Ruby on Rails](https://img.shields.io/badge/Ruby_on_Rails-CC0000?style=for-the-badge&logo=ruby-on-rails&logoColor=white)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)](https://tailwindcss.com/)
[![Ruby](https://img.shields.io/badge/Ruby-3.2.0-CC342D?style=for-the-badge&logo=ruby&logoColor=white)](https://www.ruby-lang.org/)

## 📌 プロダクト概要

行政書士・行政書士事務所向けの業務管理システムです。煩雑な許認可申請や顧客対応、期限管理を一元化し、業務の効率化を実現します。

### 🌟 主な機能
- **ダッシュボード**: 未完了の申請数、次期期限、請求総額などを一覧表示
- **申請・案件管理**: 許認可の種類、進行状況、担当者、関連書類を一元管理
- **スケジュール管理**: カレンダービューで案件の期限や顧客面談を管理
- **顧客情報管理**: 顧客情報と案件履歴を紐づけて管理

## 🚀 URL

[![Gyosei Potal](https://img.shields.io/badge/デモを見る-4285F4?style=for-the-badge&logo=google-chrome&logoColor=white)](https://gyoseipotal.onrender.com)

## BASIC認証
- **ユーザー名**: admin
- **パスワード**: gyosei_admin_2025

## アプリケーションを作成した背景
- **行政書士用の要務アプリが存在しなかったので作成しました。自分が使う際に必要と思う機能を実装しています。**

## 🌟 洗い出した要件

- **本アプリケーションを開発するにあたり、行政書士事務所の業務フローから以下の主要な要件を洗い出しました。**

1. 案件管理に関する要件

- **案件（申請）の種類、進捗、担当者、期限を正確に管理できること。**

- **案件に紐づく顧客情報を容易に参照できること。**

- **期限が近い案件や遅延している案件を警告表示できること。**

2. 顧客管理に関する要件

- **顧客の基本情報（氏名、連絡先など）を一意に管理できること。**

- **一人の顧客に対して複数の案件履歴を紐づけ、過去の依頼を追跡できること。**

3. スケジュール管理に関する要件

- **案件の申請期限や完了期限をカレンダー形式で確認できること。**

- **期限の近い順に案件をソートし、優先順位を判断できること。**

## 📸 実装した機能

### ダッシュボード
- 未完了申請数、次期期限案件、月間請求総額を一目で確認
- 期限が近い案件を優先度順に表示
- ステータス別の案件数をグラフで可視化

### 申請・案件管理
- 詳細検索機能（キーワード、ステータス、顧客、期間）
- CSVインポート機能で一括登録
- 書類ファイルの添付と管理
- 進捗状況のドラッグ＆ドロップ更新

### スケジュール管理
- カレンダービューで期限を視覚的に確認
- 期限が近い案件のアラート表示
- 顧客面談のスケジュール管理

### 顧客情報管理
- 顧客情報の詳細登録と編集
- 案件履歴の自動紐づけ表示
- 連絡先情報の一元管理

### 請求情報管理
- 申請情報・顧客情報との紐付け表示

## 🚀 実装予定の機能

### 短期的な実装予定
- [ ] **通知機能**: 期限リマインダーのメール通知
- [ ] **帳票出力**: 請求書・見積書のPDF生成
- [ ] **バックアップ機能**: データの自動バックアップと復元
- [ ] **モバイル対応**: レスポンシブデザインの改善

### 中期的な実装予定
- [ ] **AIアシスタント**: 申請書類の自動チェック機能
- [ ] **Webhook連携**: 外部サービスとの連携
- [ ] **多言語対応**: 英語・中国語での表示対応
- [ ] **リアルタイム通知**: WebSocketによる即時通知

### 長期的な実装予定
- [ ] **モバイルアプリ**: iOS/Androidアプリの開発
- [ ] **API公開**: 第三者サービスとの連携用API
- [ ] **機械学習**: 業務効率化の提案機能

## 🗄️ データベース設計

### ER図

[![Image from Gyazo](https://i.gyazo.com/8af3d4266d7c453fdab11b9815010324.png)](https://gyazo.com/8af3d4266d7c453fdab11b9815010324)

### テーブル詳細

#### customers（顧客マスタ）
- **code**: 顧客コード（一意）
- **name**: 氏名（必須）
- **company_name**: 会社名
- **kana**: フリガナ
- **email**: メールアドレス（一意）
- **phone**: 電話番号
- **address**: 住所
- **notes**: メモ
- **status**: ステータス（0: 見込み客, 1: アクティブ, 2: 非アクティブ）

#### applications（申請・案件）
- **customer_id**: 顧客ID（外部キー）
- **title**: 申請タイトル
- **status**: ステータス（0: 下書き, 1: 提出済, 2: 審査中, 3: 承認済, 4: 却下）
- **due_on**: 期限日
- **notes**: メモ

#### invoices（請求書）
- **customer_id**: 顧客ID（外部キー）
- **application_id**: 申請ID（外部キー）
- **amount_yen**: 請求額（円）
- **issued_on**: 発行日
- **status**: ステータス（0: 下書き, 1: 発行済, 2: 支払済, 3: キャンセル）

#### destinations（提出先マスタ）
- **name**: 提出先名（一意）
- **notes**: メモ
- **kind**: 種別（0: 市区町村, 1: 都道府県, 2: 国, 9: その他）

#### ActiveStorage関連テーブル
- **active_storage_blobs**: ファイル本体のメタデータ
- **active_storage_attachments**: モデルとファイルの関連付け
- **active_storage_variant_records**: ファイルのバリアント情報

### リレーションシップの特徴
- **顧客中心**: 顧客を起点に申請・請求情報が連携
- **申請-請求連携**: 申請と請求は多対多の関係（1申請に対して複数請求可能）
- **ファイル管理**: ActiveStorageによる申請書類の添付機能
- **マスタデータ**: 提出先情報をマスタとして独立管理

## 📱 画面遷移図

[![Image from Gyazo](https://i.gyazo.com/ff9bd1b6c4b8b6dec77c600c58995874.png)](https://gyazo.com/ff9bd1b6c4b8b6dec77c600c58995874)

## 💻 開発環境

### 必要なソフトウェア
- **Ruby**: 3.2.0
- **Rails**: 7.1.0
- **Bundler**: 最新版
- **MySQL**: 8.0+ (開発環境)
- **PostgreSQL**: 13+ (本番環境)
- **Node.js**: 16+
- **Yarn**: 1.22+

### 開発ツール
- **IDE**: VS Code / RubyMine
- **Git**: バージョン管理
- **Docker**: コンテナ環境（任意）
- **Postman**: APIテスト（任意）

## 🚀 ローカルでの動作方法

### 1. リポジトリのクローン
```bash
git clone https://github.com/yuki-kubouchi/GyoseiPotal.git
cd GyoseiPotal
```

### 2. Ruby環境のセットアップ
```bash
# Rubyバージョン確認
ruby -v  # 3.2.0であることを確認

# Bundlerインストール
gem install bundler
```

### 3. 依存関係のインストール
```bash
# Gemパッケージのインストール
bundle install

# Node.jsパッケージのインストール
yarn install
```

### 4. データベースのセットアップ
```bash
# データベース作成
bin/rails db:create

# マイグレーション実行
bin/rails db:migrate

# 初期データ投入（任意）
bin/rails db:seed
```

### 5. サーバーの起動
```bash
# 開発サーバー起動
bin/dev
```

### 6. アプリケーションへのアクセス
1. ブラウザで `http://localhost:3000` にアクセス
2. Basic認証ダイアログが表示されたら以下の情報を入力：
   - ユーザー名: `admin`
   - パスワード: `gyosei_admin_2025`
3. ダッシュボード画面が表示されれば成功

### トラブルシューティング
- **サーバーが起動しない場合**: `bin/rails server` で直接起動
- **データベースエラー**: MySQLが起動しているか確認
- **ポート3000が使用中**: `PORT=3001 bin/dev` でポート変更

## 💡 工夫したポイント

### 1. UI/UXの改善
- **レスポンシブデザイン**: モバイル端末でも快適に操作できるよう最適化
- **直感的な操作**: ドラッグ＆ドロップでのステータス更新など
- **視覚的なフィードバック**: ローディングアニメーションやトースト通知

### 2. パフォーマンス最適化
- **N+1クエリ対策**: `includes`メソッドでの関連データ一括読み込み
- **ページネーション**: Kaminariによる大量データの分割表示
- **非同期処理**: Turboによる部分更新でUX向上

### 3. セキュリティ対策
- **Basic認証**: 簡単ながら効果的なアクセス制限
- **CSRF対策**: Rails標準のCSRF保護を有効化
- **SQLインジェクション対策**: パラメータ化クエリの使用

### 4. 開発効率の向上
- **Hotwire導入**: JavaScriptを最小限に抑えたリッチなUI
- **Tailwind CSS**: コンポーネントベースの効率的なスタイリング
- **コードの再利用性**: ヘルパーメソッドやパーシャルの活用

### 5. 業務への特化
- **行政書士向けのワークフロー**: 実際の業務フローに合わせた画面設計
- **期限管理の重視**: 期限が近い案件の自動ハイライト表示
- **書類管理機能**: 添付ファイルの一元管理



## 🛠 技術スタック

### バックエンド
- **フレームワーク**: Ruby on Rails 7.1
- **言語**: Ruby 3.2.0
- **データベース**: 
  - 本番環境: PostgreSQL
  - 開発環境: MySQL 8.0+
- **Webサーバー**: Puma

### フロントエンド
- **スタイリング**: Tailwind CSS
- **インタラクション**: Hotwire (Turbo + Stimulus)
- **UIコンポーネント**: Kaminari（ページネーション）

## � 開発環境構築

### 前提条件
- Ruby 3.2.0
- Bundler
- MySQL 8.0+
- Node.js 16+

### セットアップ手順

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/yuki-kubouchi/GyoseiPotal.git
   cd GyoseiPotal
   ```

2. **依存関係のインストール**
   ```bash
   bundle install
   yarn install
   ```

3. **データベースのセットアップ**
   ```bash
   # データベース作成
   bin/rails db:create
   
   # マイグレーションの実行
   bin/rails db:migrate
   
   # テストデータの投入（必要な場合）
   bin/rails db:seed
   ```

4. **サーバーの起動**
   ```bash
   bin/dev
   ```
   - ブラウザで http://localhost:3000 にアクセス

## 🧪 テストの実行
```bash
# テストの実行
bundle exec rspec

# カバレッジの確認（simplecovを使用）
open coverage/index.html
```

## 🌍 デプロイ

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

### 環境変数
- `DATABASE_URL`: PostgreSQL接続URL
- `RAILS_MASTER_KEY`: 本番環境用の`config/credentials.yml.enc`を復号化するためのキー（非公開）
- `RAILS_SERVE_STATIC_FILES`: `true`に設定

## 👥 コントリビューション

1. リポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. プッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストをオープン

## � ライセンス

本プロジェクトは [MIT ライセンス](LICENSE) の下で公開されています。

## 👤 開発者

**窪内 佑樹**
- GitHub: [yuki-kubouchi](https://github.com/yuki-kubouchi)
- ポートフォリオ: [準備中]
