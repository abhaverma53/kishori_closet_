require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  setup do
    @customer = create_customer(email: "buyer@example.com", name: "Buyer")
    @admin = create_admin(email: "owner@example.com")
    product = create_product
    variant = product.product_variants.find_by!(size: "M")
    @order = @customer.orders.create!(
      subtotal: product.price,
      shipping_fee: 0,
      total: product.price,
      payment_method: "UPI",
      payment_status: "paid",
      order_status: "confirmed",
      customer_name: "Buyer",
      customer_phone: "9876543210",
      address_line_1: "12 MG Road",
      city: "Pune",
      state: "Maharashtra",
      pincode: "411001"
    )
    @order.order_items.create!(
      product: product,
      product_variant: variant,
      product_name: product.name,
      size: "M",
      sku: variant.sku,
      quantity: 1,
      price: product.price,
      total: product.price
    )
  end

  test "customer order email" do
    mail = OrderMailer.customer_order(@order)
    assert_equal [@customer.email], mail.to
    assert_match @order.order_number, mail.subject
    assert_match "UPI payment", mail.body.encoded
    assert_match "1,499", mail.body.encoded
  end

  test "admin order email" do
    mail = OrderMailer.admin_order(@order)
    assert_equal [@admin.email], mail.to
    assert_match @order.order_number, mail.subject
    assert_match @order.customer_name, mail.body.encoded
  end
end
