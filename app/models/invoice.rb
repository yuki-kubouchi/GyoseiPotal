class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :application

  enum status: { drafted: 0, issued: 1, paid: 2, canceled: 3 }

  validates :amount_yen, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :issued_on, presence: true
end
