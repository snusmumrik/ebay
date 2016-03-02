class EbayCategory < ActiveRecord::Base
  has_many :items, foreign_key: :categoryId, primary_key: :category_id
end
