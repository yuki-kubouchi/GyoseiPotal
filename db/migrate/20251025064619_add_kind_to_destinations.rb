class AddKindToDestinations < ActiveRecord::Migration[7.1]
  def change
    add_column :destinations, :kind, :integer
  end
end
