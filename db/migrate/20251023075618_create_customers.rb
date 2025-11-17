class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :company_name
      t.string :kana
      t.string :email
      t.string :phone
      t.text :address
      t.text :notes
      t.integer :status, null: false, default: 1

      t.timestamps
    end

    add_index :customers, :code, unique: true
    add_index :customers, :email, unique: true
    add_index :customers, :status
  end
end
