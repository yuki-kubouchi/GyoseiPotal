class RemoveAmountFromInvoiceItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :invoice_items, :amount, :decimal
  end
end
