module Admin
  class ProductsController < BaseController
    before_action :set_product, only: [:edit, :update, :destroy, :toggle_active, :remove_image]

    def index
      @products = Product.includes(:category, :product_variants).order(created_at: :desc)
      @products = @products.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    end

    def new
      @product = Product.new
      build_size_variants(@product)
    end

    def create
      @product = Product.new(product_params)
      assign_variant_skus(@product)
      if @product.save
        attach_images
        redirect_to admin_products_path, notice: "Product created."
      else
        build_size_variants(@product)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      existing = @product.product_variants.index_by(&:size)
      ProductVariant::SIZES.each do |size|
        @product.product_variants.build(size: size, stock_quantity: 0) unless existing[size]
      end
    end

    def update
      if @product.update(product_params)
        attach_images
        redirect_to admin_products_path, notice: "Product updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Product deleted."
    rescue ActiveRecord::RecordNotDestroyed
      redirect_to admin_products_path, alert: "This product cannot be deleted because it is linked to orders."
    end

    def toggle_active
      @product.update!(active: !@product.active?)
      redirect_to admin_products_path, notice: "#{@product.name} is now #{@product.active? ? 'active' : 'inactive'}."
    end

    def remove_image
      image = @product.images.find(params[:image_id])
      image.purge
      redirect_to edit_admin_product_path(@product), notice: "Image removed."
    end

    private

    def set_product
      @product = Product.find_by(slug: params[:id]) || Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(
        :name, :slug, :description, :price, :sku, :category_id, :color, :fabric,
        :active, :new_arrival, :best_seller,
        product_variants_attributes: [:id, :size, :sku, :stock_quantity, :active]
      )
    end

    def build_size_variants(product)
      existing = product.product_variants.map(&:size)
      ProductVariant::SIZES.each do |size|
        product.product_variants.build(size: size, stock_quantity: 0, active: true) unless existing.include?(size)
      end
    end

    def assign_variant_skus(product)
      product.product_variants.each do |variant|
        variant.sku = "#{product.sku}-#{variant.size}" if variant.sku.blank? && product.sku.present?
      end
    end

    def attach_images
      return if params.dig(:product, :images).blank?

      @product.images.attach(params[:product][:images].reject(&:blank?))
    end
  end
end
