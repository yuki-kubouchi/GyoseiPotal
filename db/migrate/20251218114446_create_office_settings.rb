class CreateOfficeSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :office_settings do |t|
      t.string :name
      t.string :postal_code
      t.string :address
      t.string :phone
      t.string :fax
      t.string :email
      t.string :bank_name
      t.string :branch_name
      t.string :account_type
      t.string :account_number
      t.string :account_holder

      t.timestamps
    end
  end
end
