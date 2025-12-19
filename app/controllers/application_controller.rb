class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: "admin", password: "yuki2025"

  private

  def postgresql?
    return false unless ActiveRecord::Base.connected?
    
    begin
      ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
    rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::DatabaseConnectionError
      false
    end
  end
end