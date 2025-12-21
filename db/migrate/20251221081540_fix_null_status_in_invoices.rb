class FixNullStatusInInvoices < ActiveRecord::Migration[7.1]
  def up
    # まず既存のデータを整数値に変換（文字列として）
    if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgresql')
      # PostgreSQL用
      execute <<-SQL
        UPDATE invoices SET status = 
          CASE status::text
            WHEN 'draft' THEN '0'
            WHEN 'sent' THEN '1'
            WHEN 'paid' THEN '2'
            WHEN 'overdue' THEN '3'
            WHEN 'cancelled' THEN '4'
            WHEN '' THEN '0'
            WHEN 'NULL' THEN '0'
            ELSE '0'
          END
        WHERE status IS NOT NULL;
      SQL
      
      # 型をintegerに変更
      execute "ALTER TABLE invoices ALTER COLUMN status TYPE integer USING status::integer"
    else
      # SQLite用: 新しいカラムを作成してデータを移行
      add_column :invoices, :status_int, :integer
      
      execute <<-SQL
        UPDATE invoices SET status_int = 
          CASE CAST(status AS TEXT)
            WHEN 'draft' THEN 0
            WHEN 'sent' THEN 1
            WHEN 'paid' THEN 2
            WHEN 'overdue' THEN 3
            WHEN 'cancelled' THEN 4
            WHEN '' THEN 0
            ELSE 0
          END;
      SQL
      
      # 古いカラムを削除して新しいカラムをリネーム
      remove_column :invoices, :status
      rename_column :invoices, :status_int, :status
    end
    
    # nullの場合はdraftに設定
    execute "UPDATE invoices SET status = 0 WHERE status IS NULL"
  end
  
  def down
    # ロールバックは複雑なので、必要な場合は手動で対応
    raise ActiveRecord::IrreversibleMigration
  end
end
