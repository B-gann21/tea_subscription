class Api::V1::SubscriptionsController < ApplicationController
  def create
    body = JSON.parse(request.body.read, symbolize_names: true)
    customer = Customer.find(params[:customer_id])
    tea = Tea.find(body[:tea_id])

    if !["weekly", "biweekly", "monthly"].include?(body[:frequency])
      render json: { 'error': 'invalid frequency' }, status: 404
    else
      subscription = Subscription.build_from_request(body[:frequency], customer, tea)
      subscription.save
      render json: Api::V1::SubscriptionSerializer.show(subscription), status: 201
    end
  end
end
