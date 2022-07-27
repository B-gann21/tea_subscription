class Api::V1::SubscriptionsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :parse_json, :validate_frequency

  def create
    customer = Customer.find(params[:customer_id])
    tea = Tea.find(@body[:tea_id])

    subscription = Subscription.build_from_request(@body[:frequency], customer, tea)
    subscription.save
    render json: Api::V1::SubscriptionSerializer.show(subscription), status: 201
  end

  def record_not_found
    render json: { 'error': 'invalid customer_id or tea_id' }, status: 404
  end

  def parse_json
    @body = JSON.parse(request.body.read, symbolize_names: true)
  end

  def validate_frequency
    if !["weekly", "biweekly", "monthly"].include?(@body[:frequency])
      render json: { 'error': 'invalid frequency' }, status: 404
    end
  end
end
