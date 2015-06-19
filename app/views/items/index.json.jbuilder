json.array!(@items) do |item|
  json.extract! item, :id, :itemId, :title, :globalId, :subtitle, :categoryId, :categoryName, :galleryURL, :galleryPlusPictureURL, :viewItemURL, :location, :country, :shippingServiceCost, :shippingType, :shipToLocations, :currentPrice, :convertedCurrentPrice, :bidCount, :startTime, :endTime, :listingType
  json.url item_url(item, format: :json)
end
