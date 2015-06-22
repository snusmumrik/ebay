json.array!(@items) do |item|
  json.extract! item, :id, :itemId, :title, :categoryId, :categoryName, :galleryURL, :galleryPlusPictureURL, :viewItemURL, :shippingServiceCost, :shippingType, :shipToLocations, :currentPrice, :convertedCurrentPrice, :bidCount, :startTime, :endTime, :listingType
  json.url item_url(item, format: :json)
end
