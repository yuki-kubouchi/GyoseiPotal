# Render デプロイメント設定ガイド

## 現在の状態

❌ **データベース接続エラーが発生しています**

エラーメッセージ:
```
There is an issue connecting with your hostname: dpg-d4ddr6c9c44c739amkng-a
```

このエラーは、WebサービスがPostgreSQLデータベースに接続できないことを示しています。

## 解決方法

### ステップ1: PostgreSQLデータベースの確認/作成

1. **Renderダッシュボード**にログイン: https://dashboard.render.com/
2. 左メニューから **「PostgreSQL」** を選択
3. データベース一覧を確認:
   - **既存のデータベースがある場合**: 次のステップへ
   - **データベースがない場合**: 以下の手順で作成

#### 新規データベース作成手順

1. 右上の **「New +」** → **「PostgreSQL」** をクリック
2. 以下の情報を入力:
   - **Name**: `gyosei-potal-db`
   - **Database**: `gyosei_potal_production`
   - **User**: `gyosei_potal_user`
   - **Region**: Webサービスと同じリージョン（重要！）
   - **Plan**: **Free**
3. **「Create Database」** をクリック
4. データベースが作成されるまで数分待つ

### ステップ2: Internal Database URLの取得

1. 作成したPostgreSQLデータベースをクリック
2. ダッシュボード画面で **「Internal Database URL」** を探す
3. URLをコピー（例: `postgresql://user:password@dpg-xxxxx-a/database_name`）

### ステップ3: Webサービスに環境変数を設定

1. 左メニューから **「Web Services」** を選択
2. **「gyosei-potal」** サービスをクリック
3. **「Settings」** タブをクリック
4. **「Environment」** セクションまでスクロール
5. **「Add Environment Variable」** をクリック
6. 以下を入力:
   - **Key**: `DATABASE_URL`
   - **Value**: ステップ2でコピーした「Internal Database URL」
7. **「Save Changes」** をクリック

### ステップ4: ビルドコマンドの確認

1. **「Settings」** タブの **「Build & Deploy」** セクション
2. **「Build Command」** が以下になっているか確認:
   ```bash
   bundle install && bundle exec rails assets:precompile && bundle exec rails assets:clean
   ```
3. もし異なる場合は修正して **「Save Changes」**

### ステップ5: 再デプロイ

1. サービスページ右上の **「Manual Deploy」** をクリック
2. **「Clear build cache & deploy」** を選択
3. デプロイが完了するまで待つ（5-10分程度）

### ステップ6: 動作確認

1. デプロイ完了後、サービスURLにアクセス: https://gyoseipotal.onrender.com
2. Basic認証でログイン:
   - Username: `admin`
   - Password: `yuki2025`
3. ダッシュボードが正常に表示されれば成功！

## トラブルシューティング

### エラーが継続する場合

1. **ログを確認**:
   - サービスページの **「Logs」** タブで詳細なエラーメッセージを確認

2. **環境変数を確認**:
   - `DATABASE_URL` が正しく設定されているか
   - URLが「Internal Database URL」であること（「External Database URL」ではない）

3. **リージョンを確認**:
   - WebサービスとPostgreSQLデータベースが同じリージョンにあるか
   - 異なるリージョンの場合、接続が遅い、または失敗する可能性があります

4. **データベースの状態を確認**:
   - PostgreSQLダッシュボードでデータベースが「Available」状態か確認

### よくある問題

**問題1: "could not translate host name"**
- 原因: `DATABASE_URL` が設定されていない、または間違っている
- 解決: ステップ2-3を再度実行

**問題2: "connection refused"**
- 原因: データベースがまだ起動中、またはリージョンが異なる
- 解決: 数分待ってから再試行、またはリージョンを確認

**問題3: "authentication failed"**
- 原因: データベース認証情報が間違っている
- 解決: Internal Database URLを再度コピーして設定

## 自動マイグレーション

このアプリケーションは、初回起動時に以下を自動的に実行します:

1. **データベースマイグレーション**: テーブル作成
2. **シードデータ**: 初期データの投入
3. **事務所情報の初期化**: デフォルト値の設定

アプリケーション起動から約5秒後に自動実行されます。ログで確認できます:
- `🔄 Running pending migrations...`
- `✅ Migrations completed successfully`
- `✅ OfficeSetting initialized`

## サポート

問題が解決しない場合は、以下の情報を提供してください:
1. Renderのログ（Logsタブから最新100行）
2. 環境変数の設定（`DATABASE_URL`の値はマスキング）
3. データベースとWebサービスのリージョン
