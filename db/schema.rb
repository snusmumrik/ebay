# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150622000605) do

  create_table "ebay_categories", force: :cascade do |t|
    t.integer  "category_id", limit: 4
    t.integer  "parent_id",   limit: 4
    t.string   "category_1",  limit: 255
    t.string   "category_2",  limit: 255
    t.string   "category_3",  limit: 255
    t.string   "category_4",  limit: 255
    t.string   "category_5",  limit: 255
    t.string   "category_6",  limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "ebay_categories", ["category_1"], name: "index_ebay_categories_on_category_1", using: :btree
  add_index "ebay_categories", ["category_id"], name: "index_ebay_categories_on_category_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "itemId",                limit: 255
    t.string   "title",                 limit: 255
    t.string   "categoryId",            limit: 255
    t.string   "categoryName",          limit: 255
    t.string   "galleryURL",            limit: 255
    t.string   "galleryPlusPictureURL", limit: 255
    t.string   "viewItemURL",           limit: 255
    t.float    "shippingServiceCost",   limit: 24
    t.string   "shippingType",          limit: 255
    t.string   "shipToLocations",       limit: 255
    t.float    "currentPrice",          limit: 24
    t.float    "convertedCurrentPrice", limit: 24
    t.integer  "bidCount",              limit: 4
    t.datetime "startTime"
    t.datetime "endTime"
    t.string   "listingType",           limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "items", ["categoryId"], name: "index_items_on_categoryId", using: :btree
  add_index "items", ["itemId"], name: "index_items_on_itemId", using: :btree

end
