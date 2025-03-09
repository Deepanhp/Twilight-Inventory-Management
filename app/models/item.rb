class Item < ApplicationRecord
  has_many :orders
  has_many :members, through: :orders
  belongs_to :category, optional: true
  belongs_to :sub_category
  belongs_to :company

  # validates :name, presence: true
  # validates :category, presence: true

  # MEASUREMENT_CATEGORIES = {
  #   weight: ["kg", "g"],
  #   volume: ["litres", "ml"],
  #   dimensions: ["length", "length_x_breadth"]
  # }.freeze


  # attribute :measurement_category, :string

  # enum measurement_category: MEASUREMENT_CATEGORIES.keys.map(&:to_s)

  # validate :validate_measurements

  # def validate_measurements
  #   return if measurements.blank?

  #   valid_units = MEASUREMENT_CATEGORIES[measurement_category.to_sym]

  #   if valid_units.exclude?(measurements["unit"])
  #     errors.add(:measurements, "Invalid unit for #{measurement_category}")
  #   end

  #   if measurements["unit"] == "length_x_breadth"
  #     unless measurements["length"].present? && measurements["breadth"].present?
  #       errors.add(:measurements, "Both Length and Breadth are required for length x breadth")
  #     end
  #   else
  #     errors.add(:measurements, "Value must be present") unless measurements["value"].present?
  #   end
  # end

  # def default_quantity
  #   measurement_type.in?(%w[weight volume]) ? 1 : nil
  # end

  # def default_length
  #   measurement_type.in?(%w[length length_x_breadth]) ? 1.0 : nil
  # end

  # def default_breadth
  #   measurement_type == "length_x_breadth" ? 1.0 : nil
  # end

  validates :company, presence: true
  validates :category, presence: true
  validates :sub_category, presence: true
  validates :quantity, :remaining_quantity, presence: true, 
            numericality: { greater_than_or_equal_to: 0 }
  validates :remaining_quantity, numericality: { less_than_or_equal_to: :quantity }
  validate :validate_measurements

  def validate_measurements
    return unless measurements.present?

    measurements.each do |measurement|
      if category == "Rods" || category == "Pipes"
        errors.add(:measurements, "must have meter, breadth, and quantity") unless measurement.key?("meter") && measurement.key?("breadth") && measurement.key?("quantity")
      elsif category == "Barrell Oil"
        errors.add(:measurements, "must have liters") unless measurement.key?("liters")
      end
    end
  end

  def get_formatted_name
    measurement_value = measurements['meters'] || measurements['liters']
    measurement_unit = measurements['meters'] ? 'meters' : 'liters'
    
    # Use subcategory name if name is empty
    base_name = if self[:name].present?
      self[:name]
    else
      "#{category&.name} - #{sub_category&.name}"
    end

    "#{base_name} (#{measurement_value} #{measurement_unit})"
  end

  def display_name
    get_formatted_name
  end

  def name_with_measurement
    get_formatted_name
  end

  # Override name getter to always return formatted name
  def name
    get_formatted_name
  end

  def low_stock?
    return false if quantity.nil? || remaining_quantity.nil?
    remaining_quantity <= (0.25 * quantity)
  end

  def stock_status
    threshold = 0.2 # 20% threshold for low stock
    ratio = remaining_quantity.to_f / quantity
    if ratio <= threshold
      :low_stock
    else
      :normal
    end
  end

  # Method to add new stock
  def add_stock(quantity)
    self.original_quantity += quantity
    self.remaining_quantity += quantity
    save
  end
  
  # Method to reduce stock when order is placed
  def reduce_stock(quantity)
    return false if quantity > remaining_quantity
    
    self.remaining_quantity -= quantity
    save
  end
end
