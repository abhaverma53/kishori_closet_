class OrderMailer < ApplicationMailer
  def customer_order(order)
    @order = order
    mail(
      to: order.user.email,
      subject: "Your Kishori Closet order #{order.order_number}"
    )
  end

  def admin_order(order)
    @order = order
    recipients = User.admin.pluck(:email)
    recipients = [KishoriCloset::CONTACT_EMAIL] if recipients.blank?

    mail(
      to: recipients,
      subject: "New Kishori Closet order #{order.order_number}"
    )
  end
end
