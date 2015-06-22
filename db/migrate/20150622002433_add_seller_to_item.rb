class AddSellerToItem < ActiveRecord::Migration
  def change
    add_column :items, :seller, :string, after: :bidCount
  end
end
