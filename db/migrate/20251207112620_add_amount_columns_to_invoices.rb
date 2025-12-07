class AddAmountColumnsToInvoices < ActiveRecord::Migration[7.1]
  def change
    add_column :invoices, :subtotal, :decimal, precision: 10, scale: 2, default: 0, null: false
    add_column :invoices, :tax_amount, :decimal, precision: 10, scale: 2, default: 0, null: false
    add_column :invoices, :total, :decimal, precision: 10, scale: 2, default: 0, null: false
  end
end
