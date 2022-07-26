# Tea Subscription Service - A take home challenge from Turing

## Requirements:
* You will create a Rails API for a Tea Subscription Service.

## Database Schema:
<img width="957" alt="Screen Shot 2022-07-25 at 2 04 27 PM" src="https://user-images.githubusercontent.com/94757433/180865194-e1c0ee64-75d9-4204-be71-0049e4840ce4.png">


## Endpoints (click to expand):
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
{ "error": "invalid customer_id or tea_id" }
```

- if the frequency is not "weekly", "biweekly", or "monthly", i see this error with an HTTP status of 400:
```
{ "error": "invalid frequency" }
```
</details>
<br>
<details>
  <summary><b/>Cancel a customer’s tea subscription</b></summary>
  
- When I send a DELETE request to `api/v1/customers/:customer_id/subscriptions/:subscription_id`, then I see the following response with an HTTP status of 204:
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
{ "error": "invalid subscription_id" }
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
{ "error": "invalid customer_id" }
```
</details>



