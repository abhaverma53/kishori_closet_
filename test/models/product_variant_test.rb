require "test_helper"

class ProductVariantTest < ActiveSupport::TestCase
  test "tracks stock and status" do
    product = create_product(stock: { "S" => 5, "M" => 0, "L" => 2 })
    medium = product.product_variants.find_by!(size: "M")
    small = product.product_variants.find_by!(size: "S")
    large = product.product_variants.find_by!(size: "L")

    assert medium.out_of_stock?
    assert_equal "Out of Stock", medium.stock_status
    assert_equal "In Stock", small.stock_status
    assert_equal "Low Stock", large.stock_status
    assert_equal "#{product.sku}-M", medium.sku
  end
end
