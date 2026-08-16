class ProductsController < ApplicationController
  def index
    load_filters
    @heading = "Shop"
    @products = filtered_products
  end

  def new_arrivals
    load_filters
    @heading = "New Arrivals"
    @products = filtered_products.new_arrivals
    render :index
  end

  def best_sellers
    load_filters
    @heading = "Best Sellers"
    @products = filtered_products.best_sellers
    render :index
  end

  def sale
    load_filters
    @heading = "Season Edit"
    @subtitle = "Handpicked pieces from the closet. Each piece has one price."
    @products = filtered_products.best_sellers
    render :index
  end

  def show
    @product = Product.active.includes(:category, :product_variants, images_attachments: :blob).find_by!(slug: params[:slug])
    @related = Product.active.where(category: @product.category).where.not(id: @product.id).limit(4)
  end

  private

  def load_filters
    @categories = Category.active.ordered
    @sizes = ProductVariant::SIZES
  end

  def filtered_products
    products = Product.active.includes(:category, :product_variants, images_attachments: :blob)

    if params[:q].present?
      query = "%#{sanitize_sql_like(params[:q])}%"
      products = products.left_joins(:category).where("products.name ILIKE :q OR categories.name ILIKE :q", q: query)
    end

    products = products.where(category_id: params[:category_id]) if params[:category_id].present?
    products = products.where(color: params[:color]) if params[:color].present?

    if params[:size].present?
      products = products.joins(:product_variants).where(product_variants: { size: params[:size], active: true }).distinct
    end

    products = products.where("products.price >= ?", params[:min_price]) if params[:min_price].present?
    products = products.where("products.price <= ?", params[:max_price]) if params[:max_price].present?

    if params[:availability] == "in_stock"
      products = products.joins(:product_variants).where("product_variants.stock_quantity > 0").distinct
    elsif params[:availability] == "out_of_stock"
      products = products.where.not(id: ProductVariant.where("stock_quantity > 0").select(:product_id))
    end

    case params[:sort]
    when "price_asc"
      products.price_low_to_high
    when "price_desc"
      products.price_high_to_low
    else
      products.newest
    end
  end

  def sanitize_sql_like(string)
    ActiveRecord::Base.sanitize_sql_like(string.to_s)
  end
end
