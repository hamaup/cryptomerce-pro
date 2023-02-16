class Admin::ProductsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_product, only: %i[show edit update]

  def index
    @products = Product.all
  end

  def new
    @product = Product.new
  end

  def create
    create_params = make_param(product_params)
    @product = Product.new(create_params)
    if @product.save
      redirect_to admin_product_path(@product)
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    update_params = make_param(product_params)
    if @product.update(update_params)
      redirect_to admin_product_path(@product)
    else
      render :edit
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description_ja, :description_en, :description_zh_tw, :price, :stock, :image)
  end

  def make_param(params)
    multi_description = {
      en: params[:description_en],
      ja: params[:description_ja],
      zh_tw: params[:description_zh_tw]
    }
    new_params = {
      name: params[:name],
      price: params[:price],
      stock: params[:stock],
      image: params[:image],
      description: params[:description_ja]
    }
    new_params[:multi_description] = multi_description
    new_params
  end
end
