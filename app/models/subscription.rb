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
      title: "#{customer.first_name}'s #{frequency.capitalize} #{tea.title}",
      status: 'active'
    }
    subscription = new(hash)

    case frequency
      when "monthly"
        subscription.price = 1500
      when "biweekly"
        subscription.price = 800
      when "weekly"
        subscription.price = 500
    else; end

    subscription
  end
end
