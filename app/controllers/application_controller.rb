class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: "admin", password: "gyosei_admin_2025"
end