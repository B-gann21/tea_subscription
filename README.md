# Tea Subscription Service - A take home challenge from Turing
Description:
- The task was to create a Tea Subscription API in 8 hours that has 3 endpoints:
  - Subscribe a Customer to a Tea 
  - Unsubscribe a Customer from a Tea
  - View all of a Customer's Subscriptions (whether subscribed or not)
- I decided to create 3 possible frequencies for a subscription, each with their own price:
  - Weekly: $5, Biweekly: $8, Monthly: $15
  
## Database Schema:
<img width="957" alt="Screen Shot 2022-07-25 at 2 04 27 PM" src="https://user-images.githubusercontent.com/94757433/180865194-e1c0ee64-75d9-4204-be71-0049e4840ce4.png">
  
## Requirements:
- Ruby 2.7.4
- Rails 5.2.8
- Postgres 14.3
- Bundler 2.3.8

## Local Setup:
- `fork` then `git clone` this repository
- `cd` into the root directory
- `bundle install` to install dependencies
- `rails db:{create,migrate,seed}` to create a database and seed it with default data (found in config/seeds.rb)
- `rails s` will boot up your local server on `localhost:3000`
- You're all set to make some requests!

## Running the test suite
- This project uses RSpec to test functionality. All tests are in the `spec` folder
  - running `bundle exec rspec` will run the full suite of 35 tests
  - to run a single test file, run `bundle exec rspec spec/{path}/{to}/{file}`
  - to view test coverage, you can run `open coverage/index.html` 
  
## Further Testing Info:
- This project was build using TDD: I started with Model specs, moving to Request specs to test the endpoints, and added unit tests as needed.
<details>
  <summary><b/>Testing database relationships and validations</b></summary> 
  
- Using built-in ActiveRecord validations I started by writing up model tests to ensure database relationships exist, and that data is being validated before being written to the DB. 
- All 3 models have similar structures to their relationship/validation specs. Here is the test for the Tea model:

```ruby
require 'rails_helper'

RSpec.describe Tea do
  context 'relationships' do
    it { should have_many :subscriptions }
    it { should have_many(:customers).through(:subscriptions) }
  end

  context 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :temperature }
    it { should validate_numericality_of :temperature }
    it { should validate_presence_of :brew_time }
    it { should validate_numericality_of :brew_time }
  end
end
```

</details>

<details>
  <summary><b/>Testing the endpoints with request specs</b></summary>
  
- After establishing the model relationships, I wrote up integration tests for each endpoint.
- They start by seeding the test database with Customer and Tea objects, and then walk through the process of sending GET/PATCH/POST requests, and end off by checking the structure of the JSON object being returned.
- Sad path tests are included at the bottom of each spec file
- Here is the spec for the `Subscribe a Customer to a Tea` endpoint:

```ruby
require 'rails_helper'

RSpec.describe 'Subscribing a customer to a Tea' do
  context 'happy path' do
    it 'returns JSON showing the new subscription' do
      customer = FactoryBot.create(:customer)
      tea = FactoryBot.create(:tea)

      post "/api/v1/customers/#{customer.id}/subscriptions",
        headers: {'Content-Type': 'application/json'},
        params: JSON.generate({tea_id: tea.id, frequency: "monthly" })

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
    it 'invalid customer id returns 404' do
      tea = FactoryBot.create(:tea)
      post '/api/v1/customers/1000/subscriptions',
        headers: {'Content-Type': 'application/json'},
        params: JSON.generate({tea_id: tea.id, frequency: "monthly" })

      expect(response).to_not be_successful
      expect(response).to have_http_status 404
      
      full_response = JSON.parse(response.body, symbolize_names: true)

      expect(full_response).to have_key :error
      expect(full_response[:error]).to eq 'invalid id(s)'
    end

    it 'invalid tea id returns 404' do
      customer = FactoryBot.create(:customer)
      post "/api/v1/customers/#{customer.id}/subscriptions",
        headers: {'Content-Type': 'application/json'},
        params: JSON.generate({tea_id: 1000, frequency: "monthly" })

      expect(response).to_not be_successful
      expect(response).to have_http_status 404
      
      full_response = JSON.parse(response.body, symbolize_names: true)

      expect(full_response).to have_key :error
      expect(full_response[:error]).to eq 'invalid id(s)'
    end

    it 'frequency must be weekly, biweekly, or monthly' do
      customer = FactoryBot.create(:customer)
      tea = FactoryBot.create(:tea)

      post "/api/v1/customers/#{customer.id}/subscriptions",
        headers: {'Content-Type': 'application/json'},
        params: JSON.generate({tea_id: tea.id, frequency: "skibbity bop mm dada" })
      
      expect(response).to_not be_successful
      expect(response).to have_http_status 404
      
      full_response = JSON.parse(response.body, symbolize_names: true)

      expect(full_response).to have_key :error
      expect(full_response[:error]).to eq 'invalid frequency'
    end
  end
end
```
  
</details>

<details>
  <summary><b/>Unit testing the Subscription model</b></summary> 
  
- while building functionality for the first endpoint, I decided to write up 2 Subscription class methods. Both of which are unit tested in `spec/models/subscription.rb`:

```ruby
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
```
  
</details>

## Development Testing with Postman:
  - copy this url `https://www.getpostman.com/collections/05e0a41732e51207f074`
  - open up Postman, and on the top left next to your workspace click `import`
  - at the top of the import window click `link`, paste the above link
  - click `continue` and you should see the new collection available

## Available Endpoints:
<details>
  <summary><b/>Subscribe a customer to a tea subscription</b></summary>
  
- When I send a POST request to `api/v1/customers/:customer_id/subscriptions`, with the following headers and body:

```
Headers:
{ "Content-Type": "application/json" }

Body:
{
  "tea_id": "1",
  "frequency": "monthly"         <-- other options are "weekly" and "biweekly"
}
```

- Then I see the following JSON response with an HTTP status of 201:
```
{
  "data": {
    "id": "1",
    "type": "subscription",
    "attributes": {
      "title": "Billy's Monthly Chamomile",         <-- format is "{customer name}'s {frequency} {tea name}"
      "price": 1500,          <-- price is in cents. Monthly is $15, biweekly is $8, weekly is $5
      "frequency": "monthly",
      "status": "active"
    }
  }
}
```

- If the customer_id or tea_id is invalid, then I see the following error with an HTTP status of 404:
```
{ "error": "invalid id(s)" }
```

- if the frequency is not "weekly", "biweekly", or "monthly", i see this error with an HTTP status of 400:
```
{ "error": "invalid frequency" }
```
</details>
<br>
<details>
  <summary><b/>Cancel a customer’s tea subscription</b></summary>
  
- When I send a PATCH request to `api/v1/customers/:customer_id/subscriptions/:subscription_id`, then I see the following response with an HTTP status of 204:
```
{
  "data": {
    "id": "1",
    "type": "subscription",
    "attributes": {
      "title": "Billy's Monthly Chamomile",
      "price": 1500,
      "frequency": "monthly",
      "status": "cancelled"     <-- status will be updated to "cancelled"
    }
  }
}
```

- If the subscription_id is invalid, I see the following error with an HTTP status of 404:
```
{ "error": "invalid id(s)" }
```
</details>
<br>
<details>
  <summary><b/>See all of a customer’s subsciptions (active and cancelled)</b></summary>
  
- When I get a GET request to `api/v1/customers/:customer_id/subscriptions`, then i see the following response with all of that customer's subscriptions:
```
{
  "data": [
    {
      "id": "1",
      "type": "subscription",
      "attributes": {
        "title": "Billy's Monthly Chamomile",
        "price": 1500,
        "frequency": "monthly",
        "status": "active"
      }
    },
    {
      "id": "2",
      "type": "subscription",
      "attributes": {
        "title": "Billy's Weekly Earl Grey",
        "price": 500,
        "frequency": "weekly",
        "status": "cancelled"
      }
    },
    {...}
  ]
}
```

- If the customer_id is invalid, i see this error with an HTTP status of 404:
```
{ "error": "invalid id(s)" }
```
</details>



