require "test_helper"

class CartCheckoutTest < ActionDispatch::IntegrationTest
  setup do
    @customer = create_customer
    @product = create_product
    @variant = @product.product_variants.find_by!(size: "M")
    sign_in @customer
  end

  test "add to cart" do
    post add_cart_path, params: { product_variant_id: @variant.id, quantity: 1 }
    assert_redirected_to cart_path
    item = @customer.cart.cart_items.find_by(product_variant: @variant)
    assert_equal 1, item.quantity
    assert_equal @product.price, item.price
  end

  test "cannot add out of stock size" do
    empty = @product.product_variants.create!(size: "XL", stock_quantity: 0, active: true)
    post add_cart_path, params: { product_variant_id: empty.id, quantity: 1 }
    assert_equal 0, @customer.cart.cart_items.count
  end

  test "increase and decrease cart quantity" do
    post add_cart_path, params: { product_variant_id: @variant.id, quantity: 1 }
    item = @customer.cart.cart_items.first

    patch increase_cart_path, params: { cart_item_id: item.id }
    assert_equal 2, item.reload.quantity

    patch decrease_cart_path, params: { cart_item_id: item.id }
    assert_equal 1, item.reload.quantity
  end

  test "cannot increase beyond stock" do
    post add_cart_path, params: { product_variant_id: @variant.id, quantity: 10 }
    item = @customer.cart.cart_items.first
    patch increase_cart_path, params: { cart_item_id: item.id }
    assert_equal 10, item.reload.quantity
    assert_match(/Only 10 items available/, flash[:alert])
  end

  test "remove from cart" do
    post add_cart_path, params: { product_variant_id: @variant.id, quantity: 1 }
    item = @customer.cart.cart_items.first
    delete remove_item_cart_path, params: { cart_item_id: item.id }
    assert_equal 0, @customer.cart.cart_items.count
  end

  test "checkout creates UPI order and reduces stock" do
    post add_cart_path, params: { product_variant_id: @variant.id, quantity: 1 }

    assert_no_emails do
      assert_difference("Order.count" => 1, "@variant.reload.stock_quantity" => -1) do
        post checkout_path, params: {
          checkout: {
            customer_name: "Test Customer",
            customer_phone: "9876543210",
            address_line_1: "12 MG Road",
            city: "Pune",
            state: "Maharashtra",
            pincode: "411001"
          }
        }
      end
    end

    order = Order.last
    assert_equal "UPI", order.payment_method
    assert_equal "pending", order.payment_status
    assert_equal "pending", order.order_status
    assert_equal @product.name, order.order_items.first.product_name
    assert_equal "M", order.order_items.first.size
    assert_equal 0, @customer.cart.cart_items.count
    assert_redirected_to pay_order_path(order)
  end

  test "clicking I have paid without a UTR does not confirm the order" do
    post add_cart_path, params: { product_variant_id: @variant.id, quantity: 1 }
    post checkout_path, params: {
      checkout: {
        customer_name: "Test Customer",
        customer_phone: "9876543210",
        address_line_1: "12 MG Road",
        city: "Pune",
        state: "Maharashtra",
        pincode: "411001"
      }
    }
    order = Order.last

    assert_no_emails do
      post confirm_payment_order_path(order)
    end

    order.reload
    assert_equal "pending", order.payment_status
    assert_equal "pending", order.order_status
    assert_response :unprocessable_entity
  end

  test "submitting a UTR claims payment but does not confirm until admin verifies" do
    admin = create_admin(email: "admin-orders@example.com")
    post add_cart_path, params: { product_variant_id: @variant.id, quantity: 1 }
    post checkout_path, params: {
      checkout: {
        customer_name: "Test Customer",
        customer_phone: "9876543210",
        address_line_1: "12 MG Road",
        city: "Pune",
        state: "Maharashtra",
        pincode: "411001"
      }
    }
    order = Order.last

    assert_emails 1 do
      post confirm_payment_order_path(order), params: { payment_reference: "123456789012" }
    end

    order.reload
    assert_equal "claimed", order.payment_status
    assert_equal "pending", order.order_status
    assert_equal "123456789012", order.payment_reference
    claim_mail = ActionMailer::Base.deliveries.last
    assert_equal [admin.email], claim_mail.to
    assert_match(/verify/i, claim_mail.subject)
    assert_redirected_to pay_order_path(order)

    sign_out @customer
    sign_in admin

    assert_emails 2 do
      post confirm_payment_admin_order_path(order)
    end

    order.reload
    assert_equal "paid", order.payment_status
    assert_equal "confirmed", order.order_status
    customer_mail, admin_mail = ActionMailer::Base.deliveries.last(2)
    assert_equal [@customer.email], customer_mail.to
    assert_equal [admin.email], admin_mail.to
    assert_match(/ORD-/, customer_mail.subject)
    assert_match(/1,499/, customer_mail.body.encoded)
    assert_redirected_to admin_order_path(order)
  end
end
