class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items
  belongs_to :member

  validates :member_id, presence: true
  
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
end
