require 'rails_helper'

RSpec.describe "Viewing all of a Customer's Subscriptions" do
  context 'happy path' do
    it 'shows all subscriptions, both active and cancelled' do
      customer = FactoryBot.create(:customer)
      tea1 = FactoryBot.create(:tea)
      tea2 = FactoryBot.create(:tea)
      tea_ids = [tea1.id, tea2.id]
      prices = [500, 800, 1500]
      statuses = ['active', 'cancelled']
      frequencies = ['weekly', 'biweekly', 'monthly']

      20.times do |t|
        customer.subscriptions.create!(
          tea_id: tea_ids.sample,
          title: "Subscription #{t}",
          frequency: frequencies.sample,
          price: prices.sample,
          status: statuses.sample
        )
      end

      get "/api/v1/customers/#{customer.id}/subscriptions"

      expect(response).to be_successful
      expect(response).to have_http_status 200

      full_response = JSON.parse(response.body, symbolize_names: true)
      expect(full_response).to have_key :data
      expect(full_response[:data]).to be_an Array
      expect(full_response[:data].count).to eq 20

      subs_data = full_response[:data]

      subs_data.each do |sub_data|
        expect(sub_data).to have_key :id
        expect(sub_data[:id]).to be_a String
        expect(sub_data).to have_key :type
        expect(sub_data[:type]).to eq 'subscription'
        expect(sub_data).to have_key :attributes
        expect(sub_data[:attributes]).to be_a Hash

        sub_attributes = sub_data[:attributes]
        expect(sub_attributes).to have_key :title
        expect(sub_attributes[:title]).to be_a String
        expect(sub_attributes).to have_key :price
        expect(sub_attributes[:price]).to be_an Integer
        expect(sub_attributes).to have_key :frequency
        expect(sub_attributes[:frequency]).to eq be_a String
        expect(sub_attributes).to have_key :status
        expect(sub_attributes[:status]).to eq('active').or eq('cancelled')
      end
    end
  end

  context 'sad path' do
    it 'returns 404 is the customer id is invalid' do
      customer = FactoryBot.create(:customer)
      get '/api/v1/customers/1000/subscriptions'

      expect(response).to_not be_successful
      expect(response).to have_http_status 404

      full_response = JSON.parse(response.body, symbolize_names: true)

      expect(full_response).to have_key :error
      expect(full_response[:error]).to eq 'invalid id(s)'
    end
  end
end
