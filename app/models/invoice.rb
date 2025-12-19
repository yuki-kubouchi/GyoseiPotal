class Invoice < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :application, optional: true
  has_many :invoice_items, dependent: :destroy

  accepts_nested_attributes_for :invoice_items, allow_destroy: true

  # enumは整数ベースで定義（データベースのinteger型に対応）
  enum status: { draft: 0, sent: 1, paid: 2, overdue: 3, cancelled: 4 }

  validates :invoice_number, presence: true, uniqueness: true
  validates :customer_id, presence: true
  validates :issue_date, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validates :tax_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # 小計（税抜き）を計算
  def calculate_subtotal
    invoice_items.to_a.sum(&:amount)
  end

  # 消費税額を計算
  def calculate_tax_amount
    (calculate_subtotal * (tax_rate / 100.0)).floor
  end

  # 合計金額（税込）を計算
  def calculate_total
    calculate_subtotal + calculate_tax_amount
  end

  # 小計（税抜き）- カラムまたは計算値を返す
  def subtotal
    self[:subtotal] || calculate_subtotal
  end

  # 消費税額 - カラムまたは計算値を返す
  def tax_amount
    self[:tax_amount] || calculate_tax_amount
  end

  # 合計金額（税込）- カラムまたは計算値を返す
  def total
    self[:total] || calculate_total
  end

  # 請求書番号を自動採番
  before_validation :generate_invoice_number, on: :create

  private

  def generate_invoice_number
    return if invoice_number.present?
    self.invoice_number = "INV-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(2).upcase}"
  end
end
