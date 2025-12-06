class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: "admin", password: "yuki2025"

  private

  def postgresql?
    ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
  end
end