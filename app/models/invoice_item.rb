class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # 金額（数量 × 単価）
  def amount
    return 0 if quantity.nil? || unit_price.nil?
    (quantity * unit_price).to_i
  end
end