class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :measurement_value, presence: true, numericality: { greater_than: 0 }
  validate :check_stock_availability

  private

  def check_stock_availability
    return unless quantity.present? && item.present?
    
    if quantity > item.remaining_quantity
      errors.add(:quantity, "not enough stock available. Available: #{item.remaining_quantity}")
    end
  end
end 