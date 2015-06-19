class AddIndexToItem < ActiveRecord::Migration
  def change
    add_index :items, :itemId
    add_index :items, :categoryId
  end
end
