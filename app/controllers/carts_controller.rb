class CartsController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:product, :product_variant, product: { images_attachments: :blob })
  end

  def add
    variant = ProductVariant.find(params[:product_variant_id])
    quantity = [params[:quantity].to_i, 1].max
    add_variant_to_cart(variant, quantity)

    if flash[:alert]
      redirect_back fallback_location: shop_path
    else
      redirect_to cart_path, notice: "#{variant.product.name} added to cart."
    end
  end

  def buy_now
    variant = ProductVariant.find(params[:product_variant_id])
    quantity = [params[:quantity].to_i, 1].max
    add_variant_to_cart(variant, quantity)

    if flash[:alert]
      redirect_back fallback_location: shop_path
    else
      redirect_to checkout_path
    end
  end

  def increase
    change_quantity(1)
  end

  def decrease
    change_quantity(-1)
  end

  def update_item
    item = @cart.cart_items.find(params[:cart_item_id])
    item.update_quantity!(params[:quantity].to_i)
    redirect_to cart_path, notice: "Cart updated."
  rescue ActiveRecord::RecordInvalid
    redirect_to cart_path, alert: item.errors.full_messages.to_sentence.presence || "Unable to update quantity."
  end

  def remove_item
    @cart.cart_items.find(params[:cart_item_id]).destroy
    redirect_to cart_path, notice: "Item removed from cart."
  end

  def destroy
    @cart.clear!
    redirect_to cart_path, notice: "Cart cleared."
  end

  private

  def set_cart
    @cart = current_cart
  end

  def add_variant_to_cart(variant, quantity)
    unless variant.in_stock?
      flash[:alert] = "Out of Stock"
      return
    end

    item = @cart.cart_items.find_or_initialize_by(product_variant: variant)
    item.product = variant.product
    item.price = variant.product.price
    new_quantity = item.new_record? ? quantity : item.quantity + quantity

    if new_quantity > variant.stock_quantity
      flash[:alert] = "Only #{variant.stock_quantity} items available."
      return
    end

    item.quantity = new_quantity
    item.save!
  end

  def change_quantity(delta)
    item = @cart.cart_items.find(params[:cart_item_id])
    if delta.negative?
      item.decrement_quantity!
      redirect_to cart_path, notice: "Cart updated."
    else
      item.increment_quantity!
      redirect_to cart_path, notice: "Cart updated."
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to cart_path, alert: item.errors.full_messages.to_sentence.presence || "Unable to update quantity."
  end
end
