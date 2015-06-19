class CreateEbayCategories < ActiveRecord::Migration
  def change
    create_table :ebay_categories do |t|
      t.integer :category_id
      t.integer :parent_id
      t.string :category_1
      t.string :category_2
      t.string :category_3
      t.string :category_4
      t.string :category_5
      t.string :category_6

      t.timestamps null: false
    end
  end
end
