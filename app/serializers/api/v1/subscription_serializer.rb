class Api::V1::SubscriptionSerializer
  def self.show(subscription)
    {
      data: {
        id: subscription.id.to_s,
        type: 'subscription',
        attributes: {
          title: subscription.title,
          price: subscription.price,
          frequency: subscription.frequency,
          status: subscription.status
        } 
      }
    }
  end
end
