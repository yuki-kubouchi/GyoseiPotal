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

## 🚀 デモ環境

[![Gyosei Potal](https://img.shields.io/badge/デモを見る-4285F4?style=for-the-badge&logo=google-chrome&logoColor=white)](https://gyoseipotal.onrender.com)

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
