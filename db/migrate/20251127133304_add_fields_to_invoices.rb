class AddFieldsToInvoices < ActiveRecord::Migration[7.1]
  def change
    add_column :invoices, :invoice_number, :string
    add_column :invoices, :due_date, :date
    add_column :invoices, :tax_rate, :decimal, precision: 5, scale: 2, default: 10.0
    add_column :invoices, :notes, :text
    
    # issued_on を issue_date にリネーム
    rename_column :invoices, :issued_on, :issue_date
    
    # status カラムを文字列に変更
    change_column :invoices, :status, :string, default: 'draft'
  end
end
