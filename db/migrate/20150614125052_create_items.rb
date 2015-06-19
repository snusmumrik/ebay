class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :itemId
      t.string :title
      t.string :globalId
      t.string :subtitle
      t.string :categoryId
      t.string :categoryName
      t.string :galleryURL
      t.string :galleryPlusPictureURL
      t.string :viewItemURL
      t.string :location
      t.string :country
      t.float :shippingServiceCost
      t.string :shippingType
      t.string :shipToLocations
      t.float :currentPrice
      t.float :convertedCurrentPrice
      t.integer :bidCount
      t.datetime :startTime
      t.datetime :endTime
      t.string :listingType

      t.timestamps null: false
    end
  end
end
