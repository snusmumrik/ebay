class AddIndexToEbayCategory < ActiveRecord::Migration
  def change
    add_index :ebay_categories, :category_id
    add_index :ebay_categories, :category_1
  end
end
