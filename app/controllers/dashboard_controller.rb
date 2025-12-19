class DashboardController < ApplicationController
  rescue_from ActiveRecord::DatabaseConnectionError, ActiveRecord::ConnectionNotEstablished do |exception|
    render plain: "データベース接続エラー: #{exception.message}\n\nRenderダッシュボードでDATABASE_URL環境変数が正しく設定されているか確認してください。", status: 503
  end

  def index
    # データベースアダプタに応じた日付フォーマット関数を取得
    date_format = if postgresql?
      "to_char(created_at, 'YYYY年MM月')"
    else
      "strftime('%Y年%m月', created_at)"
    end
    
    # ダッシュボード用のデータ
    @incomplete_count = Application.where.not(status: Application.statuses[:approved]).count
    
    # データ分析用のデータ - 月別申請件数
    @monthly_applications = Application
      .where(created_at: 6.months.ago.beginning_of_month..Time.current.end_of_month)
      .group(Arel.sql(date_format))
      .order(Arel.sql(date_format))
      .count
    
    # ステータス別申請件数
    @status_counts = Application.group(:status).count
    
    # 月別売上データ（存在する場合）
    @monthly_revenue = if defined?(Invoice) && Invoice.column_names.include?('issue_date') && Invoice.column_names.include?('total_amount')
      invoice_date_format = if postgresql?
        "to_char(issue_date, 'YYYY年MM月')"
      else
        "strftime('%Y年%m月', issue_date)"
      end
      
      Invoice
        .where(issue_date: 6.months.ago.beginning_of_month..Time.current.end_of_month)
        .where(status: ['sent', 'paid'])
        .group(Arel.sql(invoice_date_format))
        .order(Arel.sql(invoice_date_format))
        .sum(:total_amount)
    else
      {}
    end
    @next_due_application = Application.where.not(due_on: nil).order(due_on: :asc).first
    @approved_this_month = Application.approved.where(due_on: Time.current.all_month).count
    
    # 今月の請求総額を計算
    @invoice_total_yen = if defined?(Invoice)
      # 既存レコードのカラム値を使用
      Invoice.where(issue_date: Time.current.all_month)
             .where(status: ['sent', 'paid'])
             .sum(:total)
    else
      0
    end
    
    @top_applications = Application
      .where(status: [Application.statuses[:draft], Application.statuses[:submitted], Application.statuses[:reviewing]])
      .where.not(due_on: nil)
      .includes(:customer)
      .order(due_on: :asc)
      .limit(5)
      
    @upcoming_applications = Application
      .where.not(due_on: nil)
      .where('due_on >= ?', Date.current)
      .includes(:customer)
      .order(due_on: :asc)
      .limit(10)
  end
  
  def analysis
    # データベースアダプタに応じた日付フォーマット関数を取得
    date_format = if postgresql?
      "to_char(created_at, 'YYYY年MM月')"
    else
      "strftime('%Y年%m月', created_at)"
    end
    
    # 1. 月別申請件数（過去6ヶ月）
    @monthly_applications = Application
      .where(created_at: 6.months.ago.beginning_of_month..Time.current.end_of_month)
      .group(Arel.sql(date_format))
      .order(Arel.sql(date_format))
      .count
    
    # 2. ステータス別申請件数（日本語ラベルに変換）
    status_names = {
      'draft' => '下書き',
      'submitted' => '提出済み',
      'reviewing' => '審査中',
      'approved' => '承認済み',
      'rejected' => '却下'
    }
    
    status_counts = Application.group(:status).count
    @status_counts = status_counts.transform_keys { |k| status_names[k] || k }
    
    # 3. 月別売上（過去6ヶ月）
    @monthly_revenue = if defined?(Invoice) && Invoice.column_names.include?('issue_date') && Invoice.column_names.include?('total_amount')
      invoice_date_format = if postgresql?
        "to_char(issue_date, 'YYYY年MM月')"
      else
        "strftime('%Y年%m月', issue_date)"
      end
      
      Invoice
        .where(issue_date: 6.months.ago.beginning_of_month..Time.current.end_of_month)
        .where(status: ['sent', 'paid'])
        .group(Arel.sql(invoice_date_format))
        .order(Arel.sql(invoice_date_format))
        .sum(:total_amount)
    else
      {}
    end
    
    render 'analysis'
  end
end