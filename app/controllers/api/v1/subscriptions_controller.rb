class Api::V1::SubscriptionsController < ApplicationController
  def create
    body = JSON.parse(request.body.read, symbolize_names: true)
    customer = Customer.find(params[:customer_id])
    tea = Tea.find(body[:tea_id])

    subscription = Subscription.build_from_request(body[:frequency], customer, tea)

    render json: Api::V1::SubscriptionSerializer.show(subscription)
  end
end
