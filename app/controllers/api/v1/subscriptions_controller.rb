class Api::V1::SubscriptionsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action(
    :parse_json,
    :validate_frequency,
    :get_customer,
    :get_tea,
    only: :create
  )

  def create
    subscription = Subscription.build_from_request(@body[:frequency], @customer, @tea)
    subscription.save
    render json: Api::V1::SubscriptionSerializer.show(subscription), status: 201
  end

  def destroy
    subscription = Subscription.find(params[:id])
    subscription.status = 'cancelled'
    subscription.save
    render json: Api::V1::SubscriptionSerializer.show(subscription), status: 202
  end

  private
  def record_not_found
    render json: { 'error': 'invalid id(s)' }, status: 404
  end

  def parse_json
    @body = JSON.parse(request.body.read, symbolize_names: true)
  end

  def validate_frequency
    if !["weekly", "biweekly", "monthly"].include?(@body[:frequency])
      render json: { 'error': 'invalid frequency' }, status: 404
    end
  end

  def get_customer
    @customer = Customer.find(params[:customer_id])
  end

  def get_tea
    @tea = Tea.find(@body[:tea_id])
  end
end
