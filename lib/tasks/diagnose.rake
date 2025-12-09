namespace :diagnose do
  desc "Check invoice data in production"
  task check_invoices: :environment do
    puts "=== 本番環境の請求書データ診断 ==="
    puts ""
    
    puts "1. データベース接続情報:"
    puts "  Adapter: #{ActiveRecord::Base.connection.adapter_name}"
    puts "  Database: #{ActiveRecord::Base.connection.current_database}"
    puts ""
    
    puts "2. invoicesテーブルのカラム:"
    columns = ActiveRecord::Base.connection.columns(:invoices).map(&:name)
    puts "  #{columns.join(', ')}"
    puts ""
    
    puts "3. 全請求書データ:"
    Invoice.all.each do |inv|
      puts "  Invoice ##{inv.id}:"
      puts "    status: #{inv.status}"
      puts "    issue_date: #{inv.issue_date}"
      puts "    subtotal: #{inv[:subtotal]} (DB値)"
      puts "    tax_amount: #{inv[:tax_amount]} (DB値)"
      puts "    total: #{inv[:total]} (DB値)"
      puts "    calculated_total: #{inv.calculate_total}"
      puts ""
    end
    
    puts "4. 今月の送信済み/支払済み請求書:"
    today_month = Time.current.all_month
    invoices = Invoice.where(issue_date: today_month).where(status: ['sent', 'paid'])
    puts "  検索範囲: #{today_month.first} 〜 #{today_month.last}"
    puts "  該当件数: #{invoices.count}件"
    
    if invoices.any?
      invoices.each do |inv|
        puts "    - Invoice ##{inv.id}: total=#{inv[:total]}, calculated=#{inv.calculate_total}"
      end
      
      total_from_db = invoices.sum(:total)
      puts ""
      puts "  SUM(:total) = #{total_from_db}"
      puts "  期待値: 74800"
    else
      puts "  該当する請求書がありません"
    end
  end
end
