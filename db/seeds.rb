require "open3"

puts "Seeding Kishori Closet..."

image_script = Rails.root.join("db/seeds/generate_images.py")
image_dir = Rails.root.join("db/seeds/images")
unless image_dir.glob("*.jpg").any?
  stdout, stderr, status = Open3.capture3("python3", image_script.to_s)
  puts stdout
  puts stderr unless status.success?
end

OrderItem.delete_all
Order.delete_all
CartItem.delete_all
Cart.delete_all
Address.delete_all
ProductVariant.delete_all
Product.destroy_all
Category.delete_all
User.delete_all

admin = User.create!(
  name: "Kishori Admin",
  email: "admin@kishoricloset.com",
  password: "password123",
  password_confirmation: "password123",
  phone: "8722403536",
  role: :admin
)

abha = User.create!(
  name: "Abha Sharma",
  email: "abha@example.com",
  password: "password123",
  password_confirmation: "password123",
  phone: "9876543210",
  role: :customer
)

meera = User.create!(
  name: "Meera Patel",
  email: "meera@example.com",
  password: "password123",
  password_confirmation: "password123",
  phone: "9123456780",
  role: :customer
)

abha.addresses.create!(
  full_name: "Abha Sharma",
  phone: "9876543210",
  address_line_1: "14, Rose Villa",
  address_line_2: "Koregaon Park",
  city: "Pune",
  state: "Maharashtra",
  pincode: "411001"
)

categories = {
  "Western Wear" => "Clean cuts and easy everyday silhouettes.",
  "Indo-Western" => "Festive ease with a modern line.",
  "Co-ord Sets" => "Matching sets styled to wear together or apart.",
  "Dresses" => "Midi, mini and occasion dresses.",
  "Tops" => "Tops for workdays and weekends.",
  "Ethnic Wear" => "Kurtas, anarkalis and festive sets.",
  "Accessories" => "Earrings, necklaces and finishing pieces."
}.map do |name, description|
  Category.create!(name: name, description: description, active: true)
end
categories = Category.all.index_by(&:name)

products_data = [
  {
    name: "Floral Co-ord Set",
    price: 1499,
    sku: "KC-FLORAL-001",
    category: "Co-ord Sets",
    color: "Blush Pink",
    fabric: "Premium Crepe Blend",
    new_arrival: true,
    best_seller: true,
    image: "floral-coord",
    description: "A soft floral co-ord set with a relaxed shirt and matching bottom. Wear together for an easy outing look.",
    stock: { "XS" => 2, "S" => 5, "M" => 10, "L" => 4, "XL" => 0, "XXL" => 2 }
  },
  {
    name: "Rose Garden Dress",
    price: 1799,
    sku: "KC-ROSE-002",
    category: "Dresses",
    color: "Rose",
    fabric: "Georgette",
    new_arrival: true,
    best_seller: true,
    image: "rose-dress",
    description: "A flowing midi dress with a gentle flare and comfortable lining for all-day wear.",
    stock: { "XS" => 3, "S" => 6, "M" => 8, "L" => 5, "XL" => 2, "XXL" => 1 }
  },
  {
    name: "Midnight Wrap Top",
    price: 899,
    sku: "KC-WRAP-003",
    category: "Tops",
    color: "Midnight",
    fabric: "Rayon",
    new_arrival: true,
    best_seller: false,
    image: "wrap-top",
    description: "A wrap top with a flattering tie waist. Pair with palazzos or jeans.",
    stock: { "XS" => 4, "S" => 7, "M" => 9, "L" => 6, "XL" => 3, "XXL" => 2 }
  },
  {
    name: "Ivory Palazzo Set",
    price: 2199,
    sku: "KC-IVORY-004",
    category: "Indo-Western",
    color: "Ivory",
    fabric: "Linen Blend",
    new_arrival: false,
    best_seller: true,
    image: "ivory-palazzo",
    description: "An ivory kurta and palazzo set with subtle gold piping for daytime occasions.",
    stock: { "XS" => 1, "S" => 4, "M" => 7, "L" => 4, "XL" => 2, "XXL" => 0 }
  },
  {
    name: "Blush Kurta Set",
    price: 1899,
    sku: "KC-KURTA-005",
    category: "Ethnic Wear",
    color: "Blush",
    fabric: "Cotton Silk",
    new_arrival: true,
    best_seller: false,
    image: "blush-kurta",
    description: "A breathable kurta set with embroidered yoke and straight pants.",
    stock: { "XS" => 2, "S" => 5, "M" => 6, "L" => 5, "XL" => 3, "XXL" => 1 }
  },
  {
    name: "Pearl Drop Earrings",
    price: 599,
    sku: "KC-PEARL-006",
    category: "Accessories",
    color: "Pearl White",
    fabric: "Alloy & Pearl",
    new_arrival: true,
    best_seller: true,
    image: "pearl-earrings",
    description: "Lightweight pearl drops for festive evenings and everyday polish.",
    stock: { "XS" => 8, "S" => 8, "M" => 8, "L" => 8, "XL" => 8, "XXL" => 8 }
  },
  {
    name: "Sage Linen Shirt",
    price: 1299,
    sku: "KC-SAGE-007",
    category: "Western Wear",
    color: "Sage",
    fabric: "Linen",
    new_arrival: false,
    best_seller: false,
    image: "sage-shirt",
    description: "An oversized linen shirt in sage. Tuck it in or wear open over a tank.",
    stock: { "XS" => 3, "S" => 6, "M" => 8, "L" => 5, "XL" => 4, "XXL" => 2 }
  },
  {
    name: "Burgundy Anarkali",
    price: 2499,
    sku: "KC-ANARK-008",
    category: "Ethnic Wear",
    color: "Burgundy",
    fabric: "Georgette",
    new_arrival: false,
    best_seller: true,
    image: "burgundy-anarkali",
    description: "A floor-grazing anarkali with a fitted bodice and soft flare.",
    stock: { "XS" => 1, "S" => 3, "M" => 5, "L" => 3, "XL" => 1, "XXL" => 0 }
  },
  {
    name: "Cream Midi Dress",
    price: 1599,
    sku: "KC-MIDI-009",
    category: "Dresses",
    color: "Cream",
    fabric: "Crepe",
    new_arrival: true,
    best_seller: false,
    image: "cream-midi",
    description: "A cream midi with a square neck and covered buttons down the back.",
    stock: { "XS" => 2, "S" => 4, "M" => 7, "L" => 4, "XL" => 2, "XXL" => 1 }
  },
  {
    name: "Gold Hoop Necklace",
    price: 799,
    sku: "KC-GOLD-010",
    category: "Accessories",
    color: "Gold",
    fabric: "Gold-plated alloy",
    new_arrival: false,
    best_seller: false,
    image: "gold-necklace",
    description: "Layered gold hoops on a short chain. A finishing piece for both ethnic and western looks.",
    stock: { "XS" => 10, "S" => 10, "M" => 10, "L" => 10, "XL" => 10, "XXL" => 10 }
  }
]

products_data.each do |data|
  product = Product.create!(
    name: data[:name],
    description: data[:description],
    price: data[:price],
    sku: data[:sku],
    category: categories[data[:category]],
    color: data[:color],
    fabric: data[:fabric],
    active: true,
    new_arrival: data[:new_arrival],
    best_seller: data[:best_seller]
  )

  data[:stock].each do |size, qty|
    product.product_variants.create!(
      size: size,
      stock_quantity: qty,
      active: true
    )
  end

  Dir[image_dir.join("#{data[:image]}-*.jpg").to_s].sort.each do |path|
    product.images.attach(
      io: File.open(path),
      filename: File.basename(path),
      content_type: "image/jpeg"
    )
  end
end

floral = Product.find_by!(sku: "KC-FLORAL-001")
midi = Product.find_by!(sku: "KC-MIDI-009")
floral_m = floral.product_variants.find_by!(size: "M")
midi_s = midi.product_variants.find_by!(size: "S")

order = abha.orders.create!(
  subtotal: floral.price,
  shipping_fee: 0,
  total: floral.price,
  payment_method: "COD",
  payment_status: "pending",
  order_status: "pending",
  customer_name: "Abha Sharma",
  customer_phone: "9876543210",
  address_line_1: "14, Rose Villa",
  address_line_2: "Koregaon Park",
  city: "Pune",
  state: "Maharashtra",
  pincode: "411001"
)
order.order_items.create!(
  product: floral,
  product_variant: floral_m,
  product_name: floral.name,
  size: "M",
  sku: floral_m.sku,
  quantity: 1,
  price: floral.price,
  total: floral.price
)
floral_m.decrement!(:stock_quantity, 1)

order_two = meera.orders.create!(
  subtotal: midi.price,
  shipping_fee: 0,
  total: midi.price,
  payment_method: "COD",
  payment_status: "pending",
  order_status: "delivered",
  customer_name: "Meera Patel",
  customer_phone: "9123456780",
  address_line_1: "88, Lake View",
  city: "Bengaluru",
  state: "Karnataka",
  pincode: "560001"
)
order_two.order_items.create!(
  product: midi,
  product_variant: midi_s,
  product_name: midi.name,
  size: "S",
  sku: midi_s.sku,
  quantity: 1,
  price: midi.price,
  total: midi.price
)
midi_s.decrement!(:stock_quantity, 1)

puts "Seeded admin #{admin.email}, customers #{abha.email} / #{meera.email}"
puts "Password for all sample users: password123"
puts "Products: #{Product.count}, Orders: #{Order.count}"
