# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding customers..."
[
  { code: "CUST001", name: "田中 太郎", company_name: "太陽建設", kana: "タナカ タロウ", email: "tanaka@example.com", phone: "03-0000-0001", address: "東京都千代田区1-1-1", notes: "建設業許可更新あり", status: Customer.statuses[:active] },
  { code: "CUST002", name: "山田 花子", company_name: "Food Pioneer 株式会社", kana: "ヤマダ ハナコ", email: "yamada@example.com", phone: "03-0000-0002", address: "東京都港区2-2-2", notes: "飲食業許可新規", status: Customer.statuses[:prospect] },
  { code: "CUST003", name: "佐藤 次郎", company_name: "みらいの会", kana: "サトウ ジロウ", email: "sato@example.com", phone: "03-0000-0003", address: "東京都渋谷区3-3-3", notes: "NPO設立進行中", status: Customer.statuses[:active] }
].each do |attrs|
  Customer.where(code: attrs[:code]).first_or_initialize.update!(attrs)
end
puts "Customers seeded. Count: #{Customer.count}"
