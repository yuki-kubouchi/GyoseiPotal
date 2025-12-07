namespace :invoices do
  desc "既存の請求書の金額カラムを再計算して更新"
  task recalculate_amounts: :environment do
    puts "請求書の金額を再計算しています..."
    
    count = 0
    Invoice.find_each do |invoice|
      invoice.send(:update_amounts)
      if invoice.save(validate: false)
        count += 1
        print "."
      else
        puts "\n請求書 #{invoice.invoice_number} の更新に失敗しました"
      end
    end
    
    puts "\n#{count} 件の請求書を更新しました"
  end
end
