# Auto-migrate database on application startup (production only)
# This is necessary for Render free tier where database is not available during build time

Rails.application.config.after_initialize do
  # Skip in console, rake tasks, or if database is not connected
  next if defined?(Rails::Console) || File.basename($0) == 'rake' || !ActiveRecord::Base.connected?
  
  # Only run in production environment
  next unless Rails.env.production?
  
  begin
    # Check if database connection is available
    ActiveRecord::Base.connection.active?
    
    # Check if migrations are pending
    if ActiveRecord::Base.connection.migration_context.needs_migration?
      Rails.logger.info "Running pending migrations..."
      ActiveRecord::Tasks::DatabaseTasks.migrate
      Rails.logger.info "Migrations completed successfully"
      
      # Run seeds after migration
      Rails.logger.info "Loading seed data..."
      load Rails.root.join('db', 'seeds.rb')
      Rails.logger.info "Seed data loaded successfully"
    else
      Rails.logger.debug "No pending migrations"
    end
    
  rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad, ActiveRecord::StatementInvalid => e
    Rails.logger.debug "Skipping auto-migration: #{e.class}"
  rescue => e
    Rails.logger.error "Failed to run auto-migration: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
