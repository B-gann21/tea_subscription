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
end
