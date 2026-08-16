class PagesController < ApplicationController
  def home
    @categories = Category.active.ordered
    @new_arrivals = Product.new_arrivals.includes(:category, images_attachments: :blob).newest.limit(8)
    @best_sellers = Product.best_sellers.includes(:category, images_attachments: :blob).newest.limit(8)
    @featured = Product.active.includes(:category, images_attachments: :blob).newest.limit(8)
  end

  def about; end
  def contact; end
  def shipping; end
  def returns; end
  def faq; end
  def privacy; end
  def terms; end
end
