require 'rails_helper'

RSpec.describe Subscription do
  context 'relationships' do
    it { should belong_to :tea }
    it { should belong_to :customer }
  end

  context 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :price }
    it { should validate_numericality_of :price }
    it { should validate_presence_of :status }
    it { should define_enum_for(:status).with_values([:cancelled, :active]) }
    it { should validate_presence_of :frequency }
    it { should define_enum_for(:frequency).with_values([:weekly, :biweekly, :monthly]) } 
  end

  context 'class methods' do
    it ".build_from_request builds but doesn't save a Subscription" do
      customer = FactoryBot.create(:customer)
      tea = FactoryBot.create(:tea)
      
      subscription = Subscription.build_from_request("monthly", customer, tea)
      expected_title = "#{customer.first_name}'s Monthly #{tea.title}" 
      expect(subscription).to be_a Subscription
      expect(subscription.title).to eq expected_title 
      expect(subscription.price).to eq 1500
      expect(subscription.id).to be_nil
    end

    context '.get_price(frequency) calculates price based on frequency' do
      it 'monthly is 1500' do
        price = Subscription.get_price('monthly')
        expect(price).to eq 1500
      end

      it 'biweekly is 800' do
        price = Subscription.get_price('biweekly')
        expect(price).to eq 800
      end

      it 'weekly is 500' do
        price = Subscription.get_price('weekly')
        expect(price).to eq 500
      end
    end
  end
end
