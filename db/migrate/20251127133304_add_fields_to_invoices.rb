class AddFieldsToInvoices < ActiveRecord::Migration[7.1]
  def change
    # これらのカラムは既に存在するのでスキップ
    # add_column :invoices, :invoice_number, :string (already exists)
    # add_column :invoices, :due_date, :date (already exists)
    # add_column :invoices, :tax_rate, :decimal (already exists)
    # add_column :invoices, :notes, :text (already exists)
    
    # issued_on カラムが存在する場合のみリネーム
    if column_exists?(:invoices, :issued_on)
      rename_column :invoices, :issued_on, :issue_date
    end
    
    # status カラムが整数型の場合のみ変更
    # (既に整数型として定義されているので、このままにする)
    # change_column :invoices, :status, :string, default: 'draft'
  end
end
