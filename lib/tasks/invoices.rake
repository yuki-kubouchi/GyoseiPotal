namespace :invoices do
  desc "既存の請求書の金額カラムを再計算して更新"
  task recalculate_amounts: :environment do
    puts "請求書の金額を再計算しています..."
    
    count = 0
    Invoice.find_each do |invoice|
      invoice.update_columns(
        subtotal: invoice.calculate_subtotal,
        tax_amount: invoice.calculate_tax_amount,
        total: invoice.calculate_total
      )
      count += 1
      print "."
    end
    
    puts "\n#{count} 件の請求書を更新しました"
  end
end
