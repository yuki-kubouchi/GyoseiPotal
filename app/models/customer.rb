class Customer < ApplicationRecord
  has_many :applications, dependent: :destroy
  has_many :invoices, dependent: :destroy
  enum status: { prospect: 0, active: 1, inactive: 2 }

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, uniqueness: true, allow_nil: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "は不正な形式です" }, allow_blank: true
  validates :phone, format: { with: /\A[+\d\-()\s]{7,20}\z/, message: "は不正な形式です" }, allow_blank: true

  before_validation do
    self.email = nil if email.blank?
  end
end
