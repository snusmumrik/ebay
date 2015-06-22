class RemoveColumnsFromItem < ActiveRecord::Migration
  def up
    remove_column :items, :globalId
    remove_column :items, :subtitle
    remove_column :items, :location
    remove_column :items, :country
  end

  def down
    add_column :items, :globalId, :string, after: :title
    add_column :items, :subtitle, :string, after: :globalId
    add_column :items, :location, :string, after: :viewItemURL
    add_column :items, :country, :string, after: :location
  end
end
