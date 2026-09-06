module ApplicationHelper
  def inr(amount)
    number_to_currency(amount, unit: "₹", precision: 0, delimiter: ",")
  end

  def nav_link(name, path, extra_classes: "")
    active = current_page?(path)
    classes = [
      "uppercase tracking-[0.18em] text-xs font-medium transition",
      active ? "text-brand" : "text-navy/80 hover:text-brand",
      extra_classes
    ].join(" ")

    link_to name, path, class: classes
  end

  def product_image_tag(product, classes: "w-full h-full object-cover")
    if product.main_image
      image_tag product.main_image, class: classes, alt: product.name
    else
      content_tag :div, product.name.first(1), class: "flex items-center justify-center w-full h-full bg-cream text-brand font-serif text-4xl"
    end
  end

  def order_status_badge(status)
    colors = {
      "pending" => "bg-amber-50 text-amber-800",
      "confirmed" => "bg-sky-50 text-sky-800",
      "processing" => "bg-indigo-50 text-indigo-800",
      "packed" => "bg-violet-50 text-violet-800",
      "shipped" => "bg-blue-50 text-blue-800",
      "out_for_delivery" => "bg-cyan-50 text-cyan-800",
      "delivered" => "bg-emerald-50 text-emerald-800",
      "cancelled" => "bg-rose-50 text-rose-800",
      "returned" => "bg-stone-100 text-stone-700"
    }
    content_tag :span, status.to_s.titleize,
                class: "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium #{colors[status] || 'bg-stone-100 text-stone-700'}"
  end

  def stock_badge(status)
    colors = {
      "In Stock" => "bg-emerald-50 text-emerald-800",
      "Low Stock" => "bg-amber-50 text-amber-800",
      "Out of Stock" => "bg-rose-50 text-rose-800"
    }
    content_tag :span, status, class: "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium #{colors[status]}"
  end

  def whatsapp_url
    KishoriCloset::WHATSAPP_URL
  end

  def facebook_url
    KishoriCloset::FACEBOOK_URL
  end

  def instagram_url
    KishoriCloset::INSTAGRAM_URL
  end

  def footer_category_id(slug)
    @footer_category_ids ||= Category.active.pluck(:slug, :id).to_h
    @footer_category_ids[slug]
  end
end
