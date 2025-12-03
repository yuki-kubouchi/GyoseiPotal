class DashboardController < ApplicationController
  def index
    # Counts
    @incomplete_count = Application.where.not(status: Application.statuses[:approved]).count

    # Next due application
    @next_due_application = Application.where.not(due_on: nil).order(due_on: :asc).first

    # Approved this month
    @approved_this_month = Application.approved.where(due_on: Time.current.all_month).count

    # Top 5 in-progress applications (by nearest due date)
    @top_applications = Application.where(status: [Application.statuses[:draft], Application.statuses[:submitted], Application.statuses[:reviewing]])
                                   .where.not(due_on: nil)
                                   .includes(:customer)
                                   .order(due_on: :asc)
                                   .limit(5)

    # Upcoming schedule timeline (next items by due date)
    @upcoming_applications = Application.where.not(due_on: nil)
                                        .where('due_on >= ?', Date.current)
                                        .includes(:customer)
                                        .order(due_on: :asc)
                                        .limit(10)

    # Invoice total (this month): sum of all invoice totals for sent or paid invoices
    if defined?(Invoice)
      month_range = Time.current.all_month
      @invoice_total_yen = Invoice.where(issue_date: month_range)
                                 .where(status: ['sent', 'paid'])
                                 .includes(:invoice_items)
                                 .sum { |invoice| invoice.total }
                                 .to_i
    else
      @invoice_total_yen = 0
    end
  end

  def analysis
    # 1. 月別申請件数（過去6ヶ月）
    @monthly_applications = Application
      .where(created_at: 6.months.ago.beginning_of_month..Time.current.end_of_month)
      .group(Arel.sql("strftime('%Y-%m', created_at)"))
      .order(Arel.sql("strftime('%Y-%m', created_at)"))
      .count
      .transform_keys { |date_str| Date.parse("#{date_str}-01").strftime('%Y年%m月') }
    
    # 2. ステータス別申請件数
    @status_counts = Application.group(:status).count
    
    # 3. 月別売上（過去6ヶ月）
    if defined?(Invoice) && Invoice.column_names.include?('issue_date') && Invoice.column_names.include?('total_amount')
      @monthly_revenue = Invoice
        .where(issue_date: 6.months.ago.beginning_of_month..Time.current.end_of_month)
        .where(status: ['sent', 'paid'])
        .group(Arel.sql("strftime('%Y-%m', issue_date)"))
        .order(Arel.sql("strftime('%Y-%m', issue_date)"))
        .sum(:total_amount)
        .transform_keys { |date_str| Date.parse("#{date_str}-01").strftime('%Y年%m月') }
    else
      @monthly_revenue = {}
    end
  end
end