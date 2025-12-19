# Initialize OfficeSetting on application startup
# Skip during assets:precompile to avoid database connection issues
Rails.application.config.after_initialize do
  # Skip if we're precompiling assets or database isn't available
  next if defined?(Rails::Console) || File.basename($0) == 'rake' || !ActiveRecord::Base.connected?
  
  begin
    # Only run if the table exists and is accessible
    if ActiveRecord::Base.connection.table_exists?('office_settings')
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
    end
  rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad, ActiveRecord::StatementInvalid => e
    # Silently skip if database is not ready (e.g., during asset precompilation)
    Rails.logger.debug "Skipping OfficeSetting initialization: #{e.class}"
  rescue => e
    Rails.logger.error "Failed to initialize OfficeSetting: #{e.message}"
  end
end
