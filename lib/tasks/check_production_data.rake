namespace :production do
  desc "Check production customer and application data"
  task check_data: :environment do
    puts "=== Production Data Check ==="
    puts ""
    
    puts "All Customers:"
    Customer.all.each do |c|
      puts "  Customer ##{c.id}:"
      puts "    code: [#{c.code}]"
      puts "    name: [#{c.name}] (length: #{c.name.to_s.length})"
      puts "    company_name: [#{c.company_name}] (length: #{c.company_name.to_s.length})"
      puts "    name bytes: #{c.name.to_s.bytes.inspect}" if c.name.present?
      puts ""
    end
    
    puts "All Applications:"
    Application.all.each do |a|
      puts "  Application ##{a.id}:"
      puts "    title: [#{a.title}] (length: #{a.title.to_s.length})"
      puts "    customer_id: #{a.customer_id}"
      puts ""
    end
    
    puts "All Invoices:"
    Invoice.all.each do |inv|
      puts "  Invoice ##{inv.id}:"
      puts "    customer_id: #{inv.customer_id}"
      puts "    application_id: #{inv.application_id}"
      puts "    status: #{inv.status}"
      puts "    total: #{inv.total}"
      puts ""
    end
  end
end
