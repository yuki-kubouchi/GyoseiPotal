class RemoveSubtotalTaxAmountTotalFromInvoices < ActiveRecord::Migration[7.1]
  def change
    remove_column :invoices, :subtotal, :decimal
    remove_column :invoices, :tax_amount, :decimal
    remove_column :invoices, :total, :decimal
  end
end