# Initialize OfficeSetting on application startup
# This runs after auto_migrate.rb has completed migrations
Rails.application.config.after_initialize do
  # Skip if we're in console or running rake tasks
  next if defined?(Rails::Console) || File.basename($0) == 'rake'
  
  # Skip in Puma worker processes (only run in master)
  next if ENV['PUMA_CLUSTER_WORKER_INDEX']
  
  begin
    # Check if database connection is available
    next unless ActiveRecord::Base.connection.active?
    
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
        Rails.logger.info "✅ OfficeSetting initialized with default values"
      else
        Rails.logger.info "✅ OfficeSetting already exists"
      end
    else
      Rails.logger.warn "⚠️ office_settings table does not exist yet"
    end
  rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad => e
    Rails.logger.warn "⚠️ Database not available: #{e.class}"
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.warn "⚠️ Database error: #{e.message}"
  rescue => e
    Rails.logger.error "❌ Failed to initialize OfficeSetting: #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    # Don't re-raise - allow the app to start
  end
end
