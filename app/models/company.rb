class Company < ApplicationRecord
  has_many :orders
  has_many :items
  has_many :users
  has_many :members
end