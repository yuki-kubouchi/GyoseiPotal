class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: "admin", password: "yuki2025"
  
  rescue_from ActiveRecord::DatabaseConnectionError, ActiveRecord::ConnectionNotEstablished do |exception|
    logger.error "Database connection error: #{exception.message}"
    
    render html: <<~HTML.html_safe, status: 503, layout: false
      <!DOCTYPE html>
      <html>
      <head>
        <title>データベース接続エラー</title>
        <style>
          body { font-family: sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
          h1 { color: #e74c3c; }
          .error { background: #fef3f3; border: 1px solid #e74c3c; padding: 20px; border-radius: 5px; }
          .info { background: #e8f4f8; border: 1px solid #3498db; padding: 20px; border-radius: 5px; margin-top: 20px; }
          code { background: #f4f4f4; padding: 2px 5px; border-radius: 3px; }
        </style>
      </head>
      <body>
        <h1>⚠️ データベース接続エラー</h1>
        <div class="error">
          <p><strong>エラー詳細:</strong></p>
          <p>#{exception.message}</p>
        </div>
        <div class="info">
          <h2>🔧 解決方法</h2>
          <p>Renderダッシュボードで以下を確認してください:</p>
          <ol>
            <li><strong>PostgreSQLデータベースの作成:</strong>
              <ul>
                <li>Renderダッシュボード → 「New +」 → 「PostgreSQL」</li>
                <li>Name: <code>gyosei-potal-db</code></li>
                <li>Plan: Free</li>
              </ul>
            </li>
            <li><strong>環境変数の設定:</strong>
              <ul>
                <li>Webサービス「gyosei-potal」 → Settings → Environment</li>
                <li>Key: <code>DATABASE_URL</code></li>
                <li>Value: データベースの「Internal Database URL」をコピー</li>
              </ul>
            </li>
            <li><strong>サービスの再デプロイ:</strong>
              <ul>
                <li>Manual Deploy → Clear build cache & deploy</li>
              </ul>
            </li>
          </ol>
        </div>
      </body>
      </html>
    HTML
  end

  private

  def postgresql?
    return false unless ActiveRecord::Base.connected?
    
    begin
      ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
    rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::DatabaseConnectionError
      false
    end
  end
end