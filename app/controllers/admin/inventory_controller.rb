module Admin
  class InventoryController < BaseController
    def index
      @variants = ProductVariant.includes(:product).joins(:product).order("products.name", :id)
      @variants = @variants.where("products.name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    end

    def update
      variant = ProductVariant.find(params[:id])
      if variant.update(stock_quantity: params[:stock_quantity], active: params[:active].nil? ? variant.active : params[:active])
        redirect_to admin_inventory_path, notice: "Stock updated for #{variant.product.name} (#{variant.size})."
      else
        redirect_to admin_inventory_path, alert: variant.errors.full_messages.to_sentence
      end
    end
  end
end
