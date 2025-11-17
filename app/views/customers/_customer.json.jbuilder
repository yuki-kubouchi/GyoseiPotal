json.extract! customer, :id, :code, :name, :company_name, :kana, :email, :phone, :address, :notes, :status, :created_at, :updated_at
json.url customer_url(customer, format: :json)
