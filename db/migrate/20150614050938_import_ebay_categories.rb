require 'csv'    

class ImportEbayCategories < ActiveRecord::Migration
  def change
    csv_text = File.read("public/ebayCategories.csv")
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      EbayCategory.create!(row.to_hash)
    end
  end
end
