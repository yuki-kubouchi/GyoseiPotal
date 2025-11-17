json.extract! application, :id, :customer_id, :title, :status, :due_on, :notes, :created_at, :updated_at
json.url application_url(application, format: :json)
