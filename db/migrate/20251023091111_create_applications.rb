class CreateApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :applications do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :title
      t.integer :status
      t.date :due_on
      t.text :notes

      t.timestamps
    end
  end
end
