namespace :invoices do
  desc "Update invoice status for testing"
  task update_status: :environment do
    puts "=== 請求書ステータスを更新 ==="
    
    # 12月の請求書を「送信済み」に変更
    december_invoices = Invoice.where("issue_date >= ?", Date.new(2025, 12, 1))
    
    december_invoices.each do |invoice|
      old_status = invoice.status
      invoice.update(status: 'sent')
      puts "Invoice ##{invoice.id}: #{old_status} → sent (#{invoice.issue_date}, ¥#{invoice.total.to_i})"
    end
    
    puts ""
    puts "更新完了: #{december_invoices.count}件の請求書を'sent'に変更しました"
    puts ""
    
    # 確認
    sent_invoices = Invoice.where(issue_date: Time.current.all_month).where(status: ['sent', 'paid'])
    total = sent_invoices.sum(:total)
    puts "今月の送信済み/支払済み請求書総額: ¥#{total.to_i}"
  end
end
