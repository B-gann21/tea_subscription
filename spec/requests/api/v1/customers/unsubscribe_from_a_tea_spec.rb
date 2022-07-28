require 'rails_helper'

RSpec.describe 'Unsibscribing a customer from a tea' do
  context 'happy path' do
    it 'returns JSON showing the cancelled subscription' do
      customer = FactoryBot.create(:customer)
      tea = FactoryBot.create(:tea)
      customer.subscriptions.create!(
        tea_id: tea.id,
        frequency: 'monthly',
        price: 1500,
        title: 'cool title',
        status: 'active'
      )
      subscription = Subscription.all.last

      patch "/api/v1/customers/#{customer.id}/subscriptions/#{subscription.id}"

      expect(response).to be_successful
      expect(response).to have_http_status 202

      full_response = JSON.parse(response.body, symbolize_names: true)
      expect(full_response).to have_key :data
      expect(full_response[:data]).to be_a Hash

      sub_data = full_response[:data]
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
      expect(sub_attributes[:frequency]).to eq 'monthly'
      expect(sub_attributes).to have_key :status
      expect(sub_attributes[:status]).to eq 'cancelled'
    end
  end

  context 'sad path' do
    it 'invalid subscription_id results in a 404' do
      customer = FactoryBot.create(:customer)
      tea = FactoryBot.create(:tea)
      customer.subscriptions.create!(
        tea_id: tea.id,
        frequency: 'monthly',
        price: 1500,
        title: 'cool title',
        status: 'active'
      )
      subscription = Subscription.all.last

      patch "/api/v1/customers/#{customer.id}/subscriptions/1000"
      expect(response).to_not be_successful
      expect(response).to have_http_status 404
      
      full_response = JSON.parse(response.body, symbolize_names: true)
      expect(full_response).to have_key :error
      expect(full_response[:error]).to eq 'invalid id(s)'
    end
  end
end
