class FixProductionCustomerAndApplicationData < ActiveRecord::Migration[7.1]
  def up
    # Customer #3のデータを修正
    customer = Customer.find_by(id: 3)
    if customer
      customer.update!(
        name: "吉田",
        company_name: "吉田建設（株）",
        kana: "ヨシダケンセツ",
        email: "yoshida@example.com",
        phone: "090-1234-5678",
        address: "東京都新宿区1-2-3"
      )
      puts "✓ Customer #3 updated: #{customer.name} / #{customer.company_name}"
    end
    
    # Application #3のデータを修正
    application = Application.find_by(id: 3)
    if application
      application.update!(
        title: "建設業許可"
      )
      puts "✓ Application #3 updated: #{application.title}"
    end
  end

  def down
    # ロールバック時は何もしない（データ修正のため）
  end
end
