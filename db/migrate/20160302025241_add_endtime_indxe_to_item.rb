class AddEndtimeIndxeToItem < ActiveRecord::Migration
  def change
    add_index :items, :categoryName
    add_index :items, :endTime
  end
end
