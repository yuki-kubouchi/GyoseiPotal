class CreateDestinations < ActiveRecord::Migration[7.1]
  def change
    create_table :destinations do |t|
      t.string :name
      t.text :notes

      t.timestamps
    end
    add_index :destinations, :name, unique: true
  end
end
