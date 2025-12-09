# デフォルトの管理者ユーザーを作成
admin_email = "admin@example.com"
admin_password = "yuki2025"

unless User.exists?(email: admin_email)
  User.create!(
    email: admin_email,
    password: admin_password,
    password_confirmation: admin_password
  )
  puts "管理者ユーザーを作成しました。メール: #{admin_email}, パスワード: #{admin_password}"
else
  puts "管理者ユーザーは既に存在します。"
end

puts "Seeding customers..."
[
  { code: "CUST001", name: "田中 太郎", company_name: "太陽建設", kana: "タナカ タロウ", email: "tanaka@example.com", phone: "03-0000-0001", address: "東京都千代田区1-1-1", notes: "建設業許可更新あり", status: Customer.statuses[:active] },
  { code: "CUST002", name: "山田 花子", company_name: "Food Pioneer 株式会社", kana: "ヤマダ ハナコ", email: "yamada@example.com", phone: "03-0000-0002", address: "東京都港区2-2-2", notes: "飲食業許可新規", status: Customer.statuses[:prospect] },
  { code: "CUST003", name: "佐藤 次郎", company_name: "みらいの会", kana: "サトウ ジロウ", email: "sato@example.com", phone: "03-0000-0003", address: "東京都渋谷区3-3-3", notes: "NPO設立進行中", status: Customer.statuses[:active] }
].each do |attrs|
  Customer.where(code: attrs[:code]).first_or_initialize.update!(attrs)
end
puts "Customers seeded. Count: #{Customer.count}"

# 本番環境のデータ修正（Customer #3とApplication #3）
if Rails.env.production?
  puts "\n=== Fixing Production Data ==="
  
  # Customer #3を修正
  customer = Customer.find_by(id: 3)
  if customer
    puts "Fixing Customer #3..."
    customer.update!(
      name: "吉田",
      company_name: "吉田建設（株）",
      kana: "ヨシダケンセツ",
      email: "yoshida@example.com",
      phone: "090-1234-5678",
      address: "東京都新宿区1-2-3"
    )
    puts "  ✓ Customer #3 updated: #{customer.name} / #{customer.company_name}"
  else
    puts "  ⚠ Customer #3 not found"
  end
  
  # Application #3を修正
  application = Application.find_by(id: 3)
  if application
    puts "Fixing Application #3..."
    application.update!(
      title: "建設業許可"
    )
    puts "  ✓ Application #3 updated: #{application.title}"
  else
    puts "  ⚠ Application #3 not found"
  end
  
  # 検証
  puts "\n=== Verification ==="
  customer = Customer.find_by(id: 3)
  application = Application.find_by(id: 3)
  
  if customer
    puts "Customer #3:"
    puts "  name: [#{customer.name}]"
    puts "  company_name: [#{customer.company_name}]"
  end
  
  if application
    puts "Application #3:"
    puts "  title: [#{application.title}]"
  end
  
  puts "✓ Production data fixed!"
end
