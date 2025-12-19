# Auto-migrate database on application startup (production only)
# This is necessary for Render free tier where database is not available during build time

Rails.application.config.after_initialize do
  # Skip in console, rake tasks
  next if defined?(Rails::Console) || File.basename($0) == 'rake'
  
  # Only run in production environment
  next unless Rails.env.production?
  
  # Only run in the master process (not in Puma workers)
  next if ENV['PUMA_CLUSTER_WORKER_INDEX']
  
  begin
    # Check if database connection is available
    next unless ActiveRecord::Base.connection.active?
    
    # Check if migrations are pending
    if ActiveRecord::Base.connection.migration_context.needs_migration?
      Rails.logger.info "🔄 Running pending migrations..."
      
      # Use advisory lock to prevent concurrent migrations
      ActiveRecord::Base.connection.execute("SELECT pg_advisory_lock(123456789)")
      
      begin
        # Double-check if migrations are still needed (another process might have run them)
        if ActiveRecord::Base.connection.migration_context.needs_migration?
          ActiveRecord::Tasks::DatabaseTasks.migrate
          Rails.logger.info "✅ Migrations completed successfully"
          
          # Run seeds after migration
          Rails.logger.info "🌱 Loading seed data..."
          load Rails.root.join('db', 'seeds.rb')
          Rails.logger.info "✅ Seed data loaded successfully"
        end
      ensure
        # Release the lock
        ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(123456789)")
      end
    else
      Rails.logger.info "✅ Database is up to date"
    end
    
  rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad => e
    Rails.logger.warn "⚠️ Database not available yet: #{e.class}"
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.warn "⚠️ Database error during auto-migration: #{e.message}"
  rescue => e
    Rails.logger.error "❌ Failed to run auto-migration: #{e.message}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    # Don't re-raise - allow the app to start even if migration fails
  end
end
