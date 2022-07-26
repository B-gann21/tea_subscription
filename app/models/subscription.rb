class Subscription < ApplicationRecord
  belongs_to :customer
  belongs_to :tea

  validates_presence_of :title, :price, :status, :frequency 
  validates_numericality_of :price

  enum status: [:cancelled, :active]
  enum frequency: [:weekly, :biweekly, :monthly]
end
