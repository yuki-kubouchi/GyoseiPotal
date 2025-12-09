namespace :production do
  desc "Diagnose PDF data issue in production"
  task diagnose_pdf: :environment do
    puts "\n=== Production PDF Data Diagnosis ==="
    puts "Environment: #{Rails.env}"
    puts "Database: #{ActiveRecord::Base.connection.current_database}"
    puts ""
    
    # Customer #3を複数の方法で取得
    puts "1. Customer.find(3):"
    customer = Customer.find(3)
    puts "  id: #{customer.id}"
    puts "  name: [#{customer.name}]"
    puts "  name.inspect: #{customer.name.inspect}"
    puts "  name.bytes: #{customer.name.bytes.inspect}"
    puts "  name.length: #{customer.name.length}"
    puts "  company_name: [#{customer.company_name}]"
    puts "  company_name.inspect: #{customer.company_name.inspect}"
    puts ""
    
    # 直接SQLで取得
    puts "2. Direct SQL query:"
    result = ActiveRecord::Base.connection.execute("SELECT name, company_name FROM customers WHERE id = 3")
    result.each do |row|
      puts "  name: [#{row['name']}]"
      puts "  name.inspect: #{row['name'].inspect}"
      puts "  company_name: [#{row['company_name']}]"
      puts "  company_name.inspect: #{row['company_name'].inspect}"
    end
    puts ""
    
    # Application #3
    puts "3. Application.find(3):"
    application = Application.find(3)
    puts "  id: #{application.id}"
    puts "  title: [#{application.title}]"
    puts "  title.inspect: #{application.title.inspect}"
    puts "  title.bytes: #{application.title.bytes.inspect}"
    puts ""
    
    # Invoice #4経由で取得
    puts "4. Via Invoice #4:"
    invoice = Invoice.includes(:customer, :application).find(4)
    puts "  invoice.customer_id: #{invoice.customer_id}"
    puts "  invoice.customer.name: [#{invoice.customer.name}]"
    puts "  invoice.customer.name.inspect: #{invoice.customer.name.inspect}"
    puts "  invoice.application_id: #{invoice.application_id}"
    puts "  invoice.application.title: [#{invoice.application.title}]"
    puts "  invoice.application.title.inspect: #{invoice.application.title.inspect}"
    puts ""
    
    puts "=== Diagnosis Complete ==="
  end
end
