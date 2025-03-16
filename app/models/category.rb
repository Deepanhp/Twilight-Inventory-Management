class Category < ApplicationRecord
  has_many :sub_categories, dependent: :destroy
  has_many :items, through: :sub_categories
  
  validates :name, presence: true, uniqueness: true

  validate :validate_measurement_types

  def validate_measurement_types
    return if measurement_types.is_a?(Array) && measurement_types.all? { |m| m.is_a?(String) }

    errors.add(:measurement_types, "must be an array of strings")
  end

  def measurement_types
    case name
    when 'Rod'
      ['length']
    when 'Induction Rod'
      ['length']
    when 'Honning Tube'
      ['length']
    when 'Barrell Oil'
      ['volume']
    else
      []
    end
  end

  # Helper method to check if category has subcategories
  def has_subcategories?
    sub_categories.exists?
  end
end