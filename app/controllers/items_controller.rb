# -*- coding: utf-8 -*-
class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :set_affiliate_links,  only: [:index, :show]
  before_action :read_exchange_rate,  only: [:index, :show]

  # GET /items
  # GET /items.json
  def index
    if params[:category].blank?
      if params[:keyword].blank?
        if params[:category_name].blank?
          @items = Item.order_by_end_time.page params[:page]
        else
          @items = Item.search_with_category_name(params[:category_name]).order_by_end_time.page params[:page]
        end
      else
        if params[:category_name].blank?
          @items = Item.search_with_keyword(params[:keyword]).order_by_end_time.page params[:page]
        else
          @items = Item.search_with_keyword(params[:keyword]).search_with_category_name(params[:category_name]).order_by_end_time.page params[:page]
        end
      end
    else
      if params[:keyword].blank?
        if params[:category_name].blank?
          @items = Item.joins(:ebay_category).search_with_category(params[:category]).order_by_end_time.page params[:page]
        else
          @items = Item.joins(:ebay_category).search_with_category(params[:category]).search_with_category_name(params[:category_name]).order_by_end_time.page params[:page]
        end
      else
        if params[:category_name].blank?
          @items = Item.joins(:ebay_category).search_with_category(params[:category]).search_with_keyword(params[:keyword]).order_by_end_time.page params[:page]
        else
          @items = Item.joins(:ebay_category).search_with_category(params[:category]).search_with_keyword(params[:keyword]).search_with_category_name(params[:category_name]).order_by_end_time.page params[:page]
        end
      end
    end

    @count = @items.total_count

    if session[:categories]
      @categories = session[:categories]
    else
      @categories = EbayCategory.group("category_1").inject(Array.new){|a, c| a << c.category_1; a}
      session[:categories] = @categories
    end

    @latest_item = Item.order("endTime").last
    @oldest_item = Item.order("endTime").first

    if params[:category_name]
      @form_path = "#{items_path}/category/#{params[:category_name]}"
      @keyword = params[:category_name]
      @description = "#{params[:category_name]}の落札相場"
    else
      @form_path = items_path
    end

    respond_to do |format|
      format.html # index.html.erb
      format.js # index.js.erb
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @keyword = @item.title
    @description = "#{@item.title}の落札価格"
    @related_items = Item.where(["categoryId = ? AND RAND() < ?", @item.categoryId, 0.01]).limit(4)
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
    params.require(:item).permit(:itemId, :title, :categoryId, :categoryName, :galleryURL, :galleryPlusPictureURL, :viewItemURL, :shippingServiceCost, :shippingType, :shipToLocations, :currentPrice, :convertedCurrentPrice, :bidCount, :seller, :startTime, :endTime, :listingType)
  end

  def set_affiliate_links
    @amazon_associate_jp = AMAZON_ASSOCIATE_JP
    @amazon_associate_us = AMAZON_ASSOCIATE_US
  end

  def read_exchange_rate
    @rate = open("public/exchange_rate.txt", "r").read.to_f.round(2)
  end
end
