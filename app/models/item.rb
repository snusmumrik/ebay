# -*- coding: utf-8 -*-
require "mechanize"
require 'open-uri'

class Item < ActiveRecord::Base
  validates :itemId, uniqueness: true

  paginates_per 21

  scope :search_with_category, ->(category) { where(["ebay_categories.category_1 = ?", category]) }
  scope :search_with_keyword, ->(keyword) { where(["title LIKE ?", "%#{keyword}%"]) }
  scope :search_with_category_name, ->(category_name) { where(["categoryName = ?", category_name]) }
  # scope :search_with_low_price, ->(low_price) { where(["currentPrice >= ?", "%#{low_price}%"]) }
  # scope :search_with_high_price, ->(high_price) { where(["currentPrice <= ?", "%#{high_price}%"]) }
  scope :order_by_end_time, -> { order("endTime DESC") }

  def self.search
    EbayCategory.group(:category_id).order("category_id").find_each(batch_size: 10) do |c|
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
      item.seller = Item.get_seller(item)
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

  def self.get_seller(item = nil)
    if item.nil?
      Item.find_each(batch_size: 10) do |i|
        if i.seller.blank?
          begin
            agent = Mechanize.new
            page = agent.get(i.viewItemURL)
            result = page.search("span[class='mbg-nw']")
            if result.size > 1
              seller = result[0].text
            else
              seller = result.text
            end
            i.seller = seller
            i.save
          rescue => e
            p e.message
          end
        end
      end
    else
      begin
        agent = Mechanize.new
        page = agent.get(item.viewItemURL)
        result = page.search("span[class='mbg-nw']")
        if result.size > 1
          seller = result[0].text
        else
          seller = result.text
        end
      rescue => e
        p e.message
      end
    end
  end

  def self.tweet
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "y0zRx5o4PW1PdtaYMRuJjFCD9"
      config.consumer_secret     = "LAzHSkYokykKt30T0Iy5BfiCETWoQUFL0p1EslquhsjV1lFNyb"
      config.access_token        = "3266965915-Q09UXi9bezbKV2y03YpEE54G1WRJ6XRzo2jIL91"
      config.access_token_secret = "mnR8AeQh49ueFi7ltnIQDbmjoPh7IdPXpCyym7njmUC8N"
    end

    item = Item.order("RAND()").limit(1).first
    if item.currentPrice && item.shippingServiceCost
      rate = open("public/exchange_rate.txt", "r").read.to_f.round(2)
      price = ((item.currentPrice + item.shippingServiceCost) * rate).round

      # tweet
      Bitly.use_api_version_3
      Bitly.configure do |config|
        config.api_version = 3
        config.access_token = "c7b6ba72ff78178e3e0cc063f4823820ba2dfb01"
      end
      url = Bitly.client.shorten("http://ebay.crudoe.com/items/#{item.id}").short_url
      # image_url = Bitly.client.shorten(item.galleryPlusPictureURL).short_url
      if item.galleryPlusPictureURL
        image = open(item.galleryPlusPictureURL)
      elsif item.galleryURL
        image = open(item.galleryURL)
      end

      if image.is_a?(StringIO)
        ext = File.extname(url)
        name = File.basename(url, ext)
        Tempfile.new([name, ext])
      else
        image
      end

      text = "#{item.endTime.strftime('%m月%d日')}に#{price}円で売れました。詳細はこちら => #{url}"
      tags = [" #ebay輸出", " #副業", " #ネットビジネス", " #せどり", " #オークション"]
      tags.each do |t|
        if text.size + t.size < 110
          text += t
        end
      end
      client.update_with_media(text, image)
    else
      Item.tweet
    end
  end
end
