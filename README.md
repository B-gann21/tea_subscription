# Tea Subscription Service - A take home challenge from Turing
Description:
- The task was to create a Tea Subscription API in 8 hours that has 3 endpoints:
  - Subscribe a Customer to a Tea 
  - Unsubscribe a Customer from a Tea
  - View all of a Customer's Subscriptions (whether subscribed or not)
- I decided to create 3 possible frequencies for a subscription, each with their own price:
  - Weekly: $5
  - Biweekly: $8
  - Monthly: $15
  
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

## Database Schema:
<img width="957" alt="Screen Shot 2022-07-25 at 2 04 27 PM" src="https://user-images.githubusercontent.com/94757433/180865194-e1c0ee64-75d9-4204-be71-0049e4840ce4.png">


## Using the Endpoints (click to expand):
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



