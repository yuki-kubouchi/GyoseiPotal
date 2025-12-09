class FixProductionCustomerAndApplicationData < ActiveRecord::Migration[7.1]
  def up
    # 直接SQLでCustomer #3のデータを修正
    execute <<-SQL
      UPDATE customers
      SET name = '吉田',
          company_name = '吉田建設（株）',
          kana = 'ヨシダケンセツ',
          email = 'yoshida@example.com',
          phone = '090-1234-5678',
          address = '東京都新宿区1-2-3'
      WHERE id = 3;
    SQL
    
    # 直接SQLでApplication #3のデータを修正
    execute <<-SQL
      UPDATE applications
      SET title = '建設業許可'
      WHERE id = 3;
    SQL
    
    puts "✓ Customer #3 and Application #3 updated via SQL"
  end

  def down
    # ロールバック時は何もしない（データ修正のため）
  end
end
