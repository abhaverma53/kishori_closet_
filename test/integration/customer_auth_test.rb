require "test_helper"

class CustomerAuthTest < ActionDispatch::IntegrationTest
  test "customer can sign up" do
    assert_difference "User.customer.count", 1 do
      post user_registration_path, params: {
        user: {
          name: "Riya Kapoor",
          email: "riya@example.com",
          phone: "9000000000",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    user = User.find_by(email: "riya@example.com")
    assert user.customer?
    assert user.cart.present?
    assert_redirected_to root_path
  end

  test "customer can sign in" do
    user = create_customer(email: "login@example.com")
    post user_session_path, params: { user: { email: user.email, password: "password123" } }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end
end
