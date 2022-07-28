require 'factory_bot_rails'
require 'faker'
require './spec/support/factories/customer.rb'
require './spec/support/factories/tea.rb'

Subscription.destroy_all
Customer.destroy_all
Tea.destroy_all
FactoryBot.create_list(:customer, 2)
FactoryBot.create_list(:tea, 10)
