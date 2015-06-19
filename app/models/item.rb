class Item < ActiveRecord::Base
  validates :itemId, uniqueness: true

  paginates_per 21
end
