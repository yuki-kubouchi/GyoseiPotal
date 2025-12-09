namespace :production do
  desc "Fix production database data with proper values"
  task fix_data: :environment do
    puts "=== Fixing Production Data ==="
    puts ""
    
    # Fix Customer #3
    customer = Customer.find_by(id: 3)
    if customer
      puts "Fixing Customer #3..."
      customer.update!(
        code: "03",
        name: "吉田",
        company_name: "吉田建設（株）",
        kana: "ヨシダケンセツ",
        email: "example@gmail.com",
        phone: "0312345678"
      )
      puts "  ✓ Customer #3 updated: #{customer.name} / #{customer.company_name}"
    else
      puts "  ✗ Customer #3 not found"
    end
    
    # Fix Application #3
    application = Application.find_by(id: 3)
    if application
      puts "Fixing Application #3..."
      application.update!(
        title: "建設業許可",
        status: "submitted"
      )
      puts "  ✓ Application #3 updated: #{application.title}"
    else
      puts "  ✗ Application #3 not found"
    end
    
    puts ""
    puts "=== Verification ==="
    customer = Customer.find_by(id: 3)
    if customer
      puts "Customer #3:"
      puts "  name: [#{customer.name}]"
      puts "  company_name: [#{customer.company_name}]"
    end
    
    application = Application.find_by(id: 3)
    if application
      puts "Application #3:"
      puts "  title: [#{application.title}]"
    end
    
    puts ""
    puts "✓ Production data fixed!"
  end
end
