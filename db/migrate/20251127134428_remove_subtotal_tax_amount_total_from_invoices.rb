class RemoveSubtotalTaxAmountTotalFromInvoices < ActiveRecord::Migration[7.1]
  def up
    # カラムが存在する場合のみ削除
    if column_exists?(:invoices, :subtotal)
      remove_column :invoices, :subtotal, :decimal
    end
    
    if column_exists?(:invoices, :tax_amount)
      remove_column :invoices, :tax_amount, :decimal
    end
    
    if column_exists?(:invoices, :total)
      remove_column :invoices, :total, :decimal
    end
  end

  def down
    # ロールバック用の処理（必要な場合）
    # 元に戻す必要がある場合は、ここにカラムを追加するコードを記述
  end
end