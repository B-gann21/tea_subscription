require 'rails_helper'

RSpec.describe 'Subscribing a customer to a Tea' do
  context 'happy path' do
    it 'returns JSON showing the new subscription' do
      customer = FactoryBot.create(:customer)
      tea = FactoryBot.create(:tea)

      post "/api/v1/customers/#{customer.id}/subscriptions",
        headers: {'Content-Type': 'application/json'},
        params: JSON.generate({'tea_id': tea.id, frequency: "monthly" })

      expect(response).to be_successful
      expect(response).to have_http_status 201

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
      expect(sub_attributes[:status]).to eq 'active'
    end
  end

  context 'sad path' do
    it 'invalid cuystomer id returns 404' do
      tea = FactoryBot.create(:tea)
      post '/api/v1/customers/1000/subscriptions',
        headers: {'Content-Type': 'application/json'},
        params: JSON.generate({'tea_id': tea.id, frequency: "monthly" })

      expect(response).to_not be_successful
      expect(response).to have_http_status 404
      
      full_response = JSON.parse(response.body, symbolize_names: true)

      expect(full_response).to have_key :error
      expect(full_response[:error]).to eq 'invalid customer_id or tea_id'
    end

    it 'invalid tea id returns 404' do
      customer = FactoryBot.create(:customer)
      post "/api/v1/customers/#{customer.id}/subscriptions",
        headers: {'Content-Type': 'application/json'},
        params: JSON.generate({'tea_id': 1000, frequency: "monthly" })

      expect(response).to_not be_successful
      expect(response).to have_http_status 404
      
      full_response = JSON.parse(response.body, symbolize_names: true)

      expect(full_response).to have_key :error
      expect(full_response[:error]).to eq 'invalid customer_id or tea_id'
    end

    it 'frequency must be weekly, biweekly, or monthly' do
      customer = FactoryBot.create(:customer)
      tea = FactoryBot.create(:tea)

      post "/api/v1/customers/#{customer.id}/subscriptions",
        headers: {'Content-Type': 'application/json'},
        params: JSON.generate({'tea_id': tea.id, frequency: "skibbity bop mm dada" })
      
      expect(response).to_not be_successful
      expect(response).to have_http_status 404
      
      full_response = JSON.parse(response.body, symbolize_names: true)

      expect(full_response).to have_key :error
      expect(full_response[:error]).to eq 'invalid frequency'
    end
  end
end
