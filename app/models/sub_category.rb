class SubCategory < ApplicationRecord
  belongs_to :category
  has_many :items
  
  validates :name, presence: true
  validates :name, uniqueness: { scope: :category_id }
end