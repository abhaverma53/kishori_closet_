class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end
end
