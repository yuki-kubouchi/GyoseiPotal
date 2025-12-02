class CreateInvoices < ActiveRecord::Migration[7.1]
  def change
    create_table :invoices do |t|
      t.references :application, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.string :invoice_number, null: false
      t.date :issue_date, null: false
      t.date :due_date, null: false
      t.integer :status, default: 0, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false, default: 0
      t.decimal :tax_rate, precision: 5, scale: 2, default: 10.0, null: false
      t.decimal :tax_amount, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true
  end
end
