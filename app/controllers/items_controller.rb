class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_affiliate_links,  only: [:index, :show]

  # GET /items
  # GET /items.json
  def index
    if params[:category].blank?
      if params[:keyword].blank?
        @items = Item.order("endTime DESC").page params[:page]
        @count = Item.count
      else
        @items = Item.where(["title LIKE ?", "%#{params[:keyword]}%"]).order("endTime DESC").page params[:page]
        @count = Item.where(["title LIKE ?", "%#{params[:keyword]}%"]).count
      end
    else
      if params[:keyword].blank?
        @items = Item.find_by_sql(["SELECT * FROM items LEFT JOIN ebay_categories ON items.categoryId = ebay_categories.category_id WHERE ebay_categories.category_1 = ?", params[:category]])
        @count = @items.count
        @items = Kaminari.paginate_array(@items).page params[:page]
      else
        @items = Item.find_by_sql(["SELECT * FROM items LEFT JOIN ebay_categories ON items.categoryId = ebay_categories.category_id WHERE ebay_categories.category_1 = ? AND items.title LIKE ?", params[:category], "%#{params[:keyword]}%"])
        @count = @items.count
        @items = Kaminari.paginate_array(@items).page params[:page]
      end
    end

    @categories = EbayCategory.group("category_1").inject(Array.new){|a, c| a << c.category_1; a}
    @latest_item = Item.order("updated_at DESC").limit(1).first

    respond_to do |format|
      format.html # index.html.erb
      format.js # index.js.erb
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @related_items = Item.where(["categoryId = ?", @item.categoryId]).order("endTime DESC").limit(4)
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_item
    @item = Item.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def item_params
    params.require(:item).permit(:itemId, :title, :globalId, :subtitle, :categoryId, :categoryName, :galleryURL, :galleryPlusPictureURL, :viewItemURL, :location, :country, :shippingServiceCost, :shippingType, :shipToLocations, :currentPrice, :convertedCurrentPrice, :bidCount, :startTime, :endTime, :listingType)
  end

  def set_affiliate_links
    @amazon_associate_jp = AMAZON_ASSOCIATE_JP
    @amazon_associate_us = AMAZON_ASSOCIATE_US
  end
end
