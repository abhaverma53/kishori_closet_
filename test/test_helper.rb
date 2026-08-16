ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    def create_customer(attrs = {})
      User.create!(
        {
          name: "Test Customer",
          email: "customer#{SecureRandom.hex(4)}@example.com",
          password: "password123",
          password_confirmation: "password123",
          phone: "9876543210",
          role: :customer
        }.merge(attrs)
      )
    end

    def create_admin(attrs = {})
      User.create!(
        {
          name: "Test Admin",
          email: "admin#{SecureRandom.hex(4)}@example.com",
          password: "password123",
          password_confirmation: "password123",
          phone: "8722403536",
          role: :admin
        }.merge(attrs)
      )
    end

    def create_category(name: "Dresses")
      Category.find_or_create_by!(name: name) do |category|
        category.description = "#{name} collection"
        category.active = true
      end
    end

    def create_product(attrs = {})
      category = attrs.delete(:category) || create_category
      stock = attrs.delete(:stock) || { "S" => 5, "M" => 10, "L" => 4 }
      product = Product.create!(
        {
          name: "Floral Dress",
          description: "A soft floral dress.",
          price: 1499,
          sku: "SKU-#{SecureRandom.hex(3).upcase}",
          category: category,
          color: "Pink",
          fabric: "Crepe",
          active: true,
          new_arrival: true,
          best_seller: false
        }.merge(attrs)
      )
      stock.each do |size, quantity|
        product.product_variants.create!(size: size, stock_quantity: quantity, active: true)
      end
      product
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
