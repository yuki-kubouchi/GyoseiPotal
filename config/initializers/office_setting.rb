# Initialize OfficeSetting on application startup
Rails.application.config.after_initialize do
  # Only run in production or when database is ready
  if ActiveRecord::Base.connection.table_exists?('office_settings')
    begin
      # Ensure at least one OfficeSetting exists
      if OfficeSetting.count == 0
        OfficeSetting.create!(
          name: '行政書士事務所',
          postal_code: '123-4567',
          address: '東京都〇〇区〇〇1-2-3',
          phone: '03-1234-5678',
          email: 'info@example.com'
        )
        Rails.logger.info "OfficeSetting initialized successfully"
      end
    rescue => e
      Rails.logger.error "Failed to initialize OfficeSetting: #{e.message}"
    end
  end
end
