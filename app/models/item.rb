require "mechanize"

class Item < ActiveRecord::Base
  validates :itemId, uniqueness: true

  paginates_per 21

  scope :search_with_category, ->(category) { where(["ebay_categories.category_1 = ?", category]) }
  scope :search_with_keyword, ->(keyword) { where(["title LIKE ?", "%#{keyword}%"]) }
  scope :search_with_category_name, ->(category_name) { where(["categoryName = ?", category_name]) }
  scope :order_by_end_time, -> { order("endTime DESC") }

  def self.search
    category_id = 0
    EbayCategory.where(["category_id > ?", category_id]).group(:category_id).order("category_id").each_with_index do |c, i|
      findCompletedItems(c)
    end
  end

  def self.findCompletedItems(category = "", keywords = "")
    for page_number in 1..100
      skip = false
      puts "#{category.category_id} #{category.category_1}>#{category.category_2}>#{category.category_3}>#{category.category_4}>#{category.category_4}>#{category.category_5} Page Number: #{page_number}\r\n\r\n"

      header = {
        "X-EBAY-SOA-SERVICE-NAME" => "FindingService",
        "X-EBAY-SOA-OPERATION-NAME" => "findCompletedItems",
        "X-EBAY-SOA-SERVICE-VERSION" => "1.13.0",
        "X-EBAY-SOA-GLOBAL-ID" => "EBAY-US",
        "X-EBAY-SOA-SECURITY-APPNAME" => APPID,
        "X-EBAY-SOA-REQUEST-DATA-FORMAT" => "XML"
      }

      xml = "<?xml version='1.0' encoding='UTF-8'?>
<findCompletedItemsRequest xmlns='http://www.ebay.com/marketplace/search/v1/services'>
  <keywords>#{keywords}</keywords>
  <categoryId>#{category.category_id}</categoryId>
  <itemFilter>
     <name>LocatedIn</name>
     <value>JP</value>
  </itemFilter>
  <itemFilter>
     <name>SoldItemsOnly</name>
     <value>true</value>
  </itemFilter>
  <sortOrder>EndTimeSoonest</sortOrder>
  <paginationInput>
     <entriesPerPage>100</entriesPerPage>
     <pageNumber>#{page_number}</pageNumber>
  </paginationInput>
</findCompletedItemsRequest>"
      # puts "#{xml}\r\n\r\n"

      response = Typhoeus::Request.post(URL, :body => xml, :headers => header )
      hash = Hash.from_xml(response.response_body)
      puts "#{hash}\r\n\r\n"

      if hash["findCompletedItemsResponse"]["ack"] == "Failure"
        skip = true
      elsif hash["findCompletedItemsResponse"]["searchResult"]["item"].kind_of?(Array)
        if hash["findCompletedItemsResponse"]["searchResult"]["count"].to_i < 100
          puts "#{category.category_id} #{category.category_1}>#{category.category_2}>#{category.category_3}>#{category.category_4}>#{category.category_4}>#{category.category_5} Last page\r\n\r\n"
          skip = true
        end

        hash["findCompletedItemsResponse"]["searchResult"]["item"].each do |i|
          puts "#{i}\r\n\r\n"

          skip = save_item(i)
          break if skip
        end
      elsif hash["findCompletedItemsResponse"]["searchResult"]["item"].kind_of?(Hash)
        skip = true
        i = hash["findCompletedItemsResponse"]["searchResult"]["item"]
        save_item(i)
      else
        puts "#{category.category_id} #{category.category_1}>#{category.category_2}>#{category.category_3}>#{category.category_4}>#{category.category_4}>#{category.category_5} No result\r\n\r\n"
        skip = true
      end

      break if skip
    end
  end

  def self.save_item(i)
    if Item.where(["itemId = ?", i["itemId"]]).first
      puts "itemId: #{i['itemId']} already saved\r\n\r\n"
      return true
    else
      item = Item.new
      item.itemId = i["itemId"]
      item.title = i["title"]
      item.categoryId = i["primaryCategory"]["categoryId"]
      item.categoryName = i["primaryCategory"]["categoryName"]
      item.galleryURL = i["galleryURL"]
      item.galleryPlusPictureURL = i["galleryPlusPictureURL"]
      item.viewItemURL = i["viewItemURL"]
      item.shippingServiceCost = i["shippingInfo"]["shippingServiceCost"]
      item.shippingType = i["shippingInfo"]["shippingType"]
      item.shipToLocations = i["shippingInfo"]["shipToLocations"]
      item.currentPrice = i["sellingStatus"]["currentPrice"]
      item.convertedCurrentPrice = i["sellingStatus"]["convertedCurrentPrice"]
      item.bidCount = i["sellingStatus"]["bidCount"]
      item.startTime = i["listingInfo"]["startTime"]
      item.endTime = i["listingInfo"]["endTime"]
      item.listingType = i["listingInfo"]["listingType"]
      item.save
      return false
    end
  end

  def self.get_exchange_rate
    begin
      agent = Mechanize.new
      agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
      page = agent.get("https://www.google.com/finance/converter?a=1&from=USD&to=JPY")
      rate = page.search("span[class='bld']").text.sub!(" JPY", "").to_f

      file = open("public/exchange_rate.txt", "w")
      file.puts rate
      file.close
    rescue => ex
      warn ex.message
    end
  end
end
