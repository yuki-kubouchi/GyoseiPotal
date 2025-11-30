class Invoice < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :application, optional: true
  has_many :invoice_items, dependent: :destroy

  accepts_nested_attributes_for :invoice_items, allow_destroy: true

  enum status: { draft: 'draft', sent: 'sent', paid: 'paid', overdue: 'overdue', cancelled: 'cancelled' }

  validates :invoice_number, presence: true, uniqueness: true
  validates :issue_date, presence: true
  validates :due_date, presence: true
  validates :status, presence: true
  validates :tax_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # 小計（税抜き）
  def subtotal
    invoice_items.sum(&:amount)
  end

  # 消費税額
  def tax_amount
    (subtotal * (tax_rate / 100.0)).floor
  end

  # 合計金額（税込）
  def total
    subtotal + tax_amount
  end

  # 請求書番号を自動採番
  before_validation :generate_invoice_number, on: :create

  private

  def generate_invoice_number
    return if invoice_number.present?

    date = Date.current.strftime('%Y%m%d')
    last_invoice = Invoice.where('invoice_number LIKE ?', "#{date}%").order(:invoice_number).last
    if last_invoice
      number = last_invoice.invoice_number[8..-1].to_i + 1
      self.invoice_number = "#{date}#{number.to_s.rjust(4, '0')}"
    else
      self.invoice_number = "#{date}0001"
    end
  end

  private

  def generate_invoice_number
    "INV-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(2).upcase}"
  end
end
