class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items
  belongs_to :member

  validates :member_id, presence: true
  validate :valid_measurements
  
  # Remove these validations as they're now handled in OrderItem
  # validates :quantity, presence: true, numericality: { greater_than: 0 }
  # validates :item_id, presence: true
  # validate :check_stock_availability
  # before_create :update_stock

  def self.active?
    Order.all
  end

  def self.inactive?
    Order.where(status: false)
  end

  def self.expired?
    Order.where("expire_at < ?", Date.today).where(status: true)
  end

  def self.renew(id)
    @order = Order.find(id)
    @order.update(expire_at: 7.days.from_now)
  end

  def self.disable(id)
    @order = Order.find(id)
    @order.update(status: false)
  end

  private

  def valid_measurements
    order_items.each do |order_item|
      item = order_item.item
      if item
        if item.category.name == 'Barrell Oil'
          if order_item.requested_measurement > item.measurements['liters'].to_f
            errors.add(:base, "Requested volume (#{order_item.requested_measurement} L) cannot exceed available volume (#{item.measurements['liters']} L) for #{item.description}")
          end
        else
          if order_item.requested_measurement > item.measurements['meters'].to_f
            errors.add(:base, "Requested length (#{order_item.requested_measurement} m) cannot exceed available length (#{item.measurements['meters']} m) for #{item.description}")
          end
        end
      end
    end
  end
end
