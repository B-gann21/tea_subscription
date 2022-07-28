class Subscription < ApplicationRecord
  belongs_to :customer
  belongs_to :tea

  validates_presence_of :title, :price, :status, :frequency 
  validates_numericality_of :price

  enum status: [:cancelled, :active]
  enum frequency: [:weekly, :biweekly, :monthly]

  def self.build_from_request(frequency, customer, tea)
    hash = {
      customer_id: customer.id,
      tea_id: tea.id,
      frequency: frequency,
      price: get_price(frequency),
      title: "#{customer.first_name}'s #{frequency.capitalize} #{tea.title}",
      status: 'active'
    }

    new(hash)
  end

  def self.get_price(frequency)
    case frequency
      when "monthly"
        1500
      when "biweekly"
        800
      when "weekly"
        500
    else; end
  end
end
