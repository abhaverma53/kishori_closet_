class Checkout
  attr_reader :user, :cart, :params, :order, :errors

  def initialize(user:, params:)
    @user = user
    @cart = user.cart
    @params = params
    @errors = []
  end

  def place_order
    if cart.blank? || cart.empty?
      errors << "Your cart is empty."
      return false
    end

    Order.transaction do
      cart.cart_items.includes(:product, :product_variant).each do |item|
        variant = ProductVariant.lock.find(item.product_variant_id)
        if variant.stock_quantity < item.quantity
          errors << "Only #{variant.stock_quantity} items available for #{item.product.name} (#{variant.size})."
        end
      end
      raise ActiveRecord::Rollback if errors.any?

      @order = user.orders.new(
        subtotal: cart.subtotal,
        shipping_fee: cart.shipping_fee,
        total: cart.total,
        payment_method: "COD",
        payment_status: "pending",
        order_status: "pending",
        customer_name: params[:customer_name],
        customer_phone: params[:customer_phone],
        address_line_1: params[:address_line_1],
        address_line_2: params[:address_line_2],
        city: params[:city],
        state: params[:state],
        pincode: params[:pincode]
      )

      unless @order.save
        errors.concat(@order.errors.full_messages)
        raise ActiveRecord::Rollback
      end

      cart.cart_items.includes(:product, :product_variant).each do |item|
        variant = ProductVariant.lock.find(item.product_variant_id)
        variant.decrement!(:stock_quantity, item.quantity)

        @order.order_items.create!(
          product: item.product,
          product_variant: variant,
          product_name: item.product.name,
          size: variant.size,
          sku: variant.sku,
          quantity: item.quantity,
          price: item.price,
          total: item.line_total
        )
      end

      save_address_if_requested
      cart.clear!
    end

    errors.empty? && order.present?
  end

  private

  def save_address_if_requested
    return unless ActiveModel::Type::Boolean.new.cast(params[:save_address])

    user.addresses.create(
      full_name: params[:customer_name],
      phone: params[:customer_phone],
      address_line_1: params[:address_line_1],
      address_line_2: params[:address_line_2],
      city: params[:city],
      state: params[:state],
      pincode: params[:pincode]
    )
  end
end
