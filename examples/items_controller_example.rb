# frozen_string_literal: true

# Example Rails controller showing how to integrate with PlaypathRails
class ItemsController < ApplicationController
  before_action :set_item, only: %i[show edit update destroy]

  # GET /items
  def index
    @items = PlaypathRails.client.list_items
  end

  # GET /items/1
  def show
    @item = PlaypathRails.client.get_item(@item.id)
  end

  # GET /items/new
  def new
    @item = {}
  end

  # GET /items/1/edit
  def edit; end

  # POST /items
  def create
    @item = PlaypathRails.client.create_item(item_params)

    if @item
      redirect_to @item, notice: 'Item was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /items/1
  def update
    if PlaypathRails.client.update_item(@item.id, item_params)
      redirect_to @item, notice: 'Item was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /items/1
  def destroy
    PlaypathRails.client.delete_item(@item.id)
    redirect_to items_url, notice: 'Item was successfully deleted.'
  end

  private

  def set_item
    @item = PlaypathRails.client.get_item(params[:id])
  end

  # Handle both nested and flat parameter structures
  def item_params
    if params[:item].present?
      # Nested parameters: { item: { title: "...", url: "...", text: "...", tags: [...] } }
      params.require(:item).permit(:title, :url, :text, tags: [])
    else
      # Flat parameters: { title: "...", url: "...", text: "...", tags: [...] }
      params.permit(:title, :url, :text, tags: [])
    end
  end
end
