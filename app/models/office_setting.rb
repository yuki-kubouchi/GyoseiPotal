class OfficeSetting < ApplicationRecord
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  
  # シングルトンパターン：1レコードのみ保持
  def self.instance
    first_or_create!(
      name: '行政書士事務所',
      postal_code: '123-4567',
      address: '東京都〇〇区〇〇1-2-3',
      phone: '03-1234-5678',
      email: 'info@example.com'
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create OfficeSetting: #{e.message}"
    first || create!(
      name: '行政書士事務所',
      postal_code: '123-4567',
      address: '東京都〇〇区〇〇1-2-3',
      phone: '03-1234-5678',
      email: 'info@example.com'
    )
  end
end
