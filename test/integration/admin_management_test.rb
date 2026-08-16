require "test_helper"

class AdminManagementTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create_admin
    @category = create_category
    sign_in @admin
  end

  test "admin can create a product with variants" do
    assert_difference "Product.count" => 1, "ProductVariant.count" => 6 do
      post admin_products_path, params: {
        product: {
          name: "Pearl Top",
          description: "A soft pearl top.",
          price: 1299,
          sku: "KC-TEST-100",
          category_id: @category.id,
          color: "Ivory",
          fabric: "Cotton",
          active: "1",
          new_arrival: "1",
          best_seller: "0",
          product_variants_attributes: ProductVariant::SIZES.each_with_index.map { |size, index|
            [index.to_s, { size: size, stock_quantity: size == "M" ? 8 : 2, active: "1" }]
          }.to_h
        }
      }
    end
    product = Product.find_by!(sku: "KC-TEST-100")
    assert product.new_arrival?
    assert_equal 8, product.product_variants.find_by(size: "M").stock_quantity
  end

  test "admin can edit a product" do
    product = create_product(category: @category, name: "Old Name")
    patch admin_product_path(product), params: {
      product: {
        name: "Updated Dress",
        price: product.price,
        sku: product.sku,
        category_id: @category.id,
        color: product.color,
        fabric: product.fabric
      }
    }
    assert_equal "Updated Dress", product.reload.name
  end

  test "admin can view customers" do
    customer = create_customer(name: "Abha Sharma")
    get admin_customers_path
    assert_response :success
    assert_match "Abha Sharma", response.body

    get admin_customer_path(customer)
    assert_response :success
    assert_match customer.email, response.body
  end

  test "admin can update order status" do
    customer = create_customer
    product = create_product(category: @category)
    variant = product.product_variants.find_by!(size: "S")
    order = customer.orders.create!(
      subtotal: product.price,
      shipping_fee: 0,
      total: product.price,
      payment_method: "COD",
      payment_status: "pending",
      order_status: "pending",
      customer_name: customer.name,
      customer_phone: "9876543210",
      address_line_1: "1 Street",
      city: "Mumbai",
      state: "Maharashtra",
      pincode: "400001"
    )
    order.order_items.create!(
      product: product,
      product_variant: variant,
      product_name: product.name,
      size: "S",
      sku: variant.sku,
      quantity: 1,
      price: product.price,
      total: product.price
    )

    patch admin_order_path(order), params: { order: { order_status: "shipped" } }
    assert_equal "shipped", order.reload.order_status
  end
end
