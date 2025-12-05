# Fetching External APIs with JSON Helpers

Quick reference guide for fetching external APIs and using JSON helpers to return data.

## Basic Pattern

```crystal
require "http/client"
require "json"

class ApiController < KothariAPI::Controller
  def index
    begin
      # 1. Make HTTP request
      response = HTTP::Client.get("https://api.example.com/data")
      
      # 2. Check status code
      return internal_server_error("API error") unless response.status_code == 200
      
      # 3. Parse JSON
      data = JSON.parse(response.body)
      
      # 4. Return using JSON helper
      json_get(data)
    rescue ex
      internal_server_error("Error: #{ex.message}")
    end
  end
end
```

## GET Request Example

```crystal
class WeatherController < KothariAPI::Controller
  def show
    city = params["city"]?.to_s
    return bad_request("City required") unless city
    
    begin
      response = HTTP::Client.get("https://api.weather.com/#{city}")
      return internal_server_error("API error") unless response.status_code == 200
      
      weather_data = JSON.parse(response.body)
      json_get(weather_data)  # Returns 200 OK
    rescue ex
      internal_server_error("Error: #{ex.message}")
    end
  end
end
```

## POST Request Example

```crystal
class PaymentController < KothariAPI::Controller
  def create
    attrs = permit_body("amount", "currency")
    
    begin
      payment_data = {
        "amount" => attrs["amount"].as_f?,
        "currency" => attrs["currency"].to_s
      }
      
      response = HTTP::Client.post(
        "https://api.payment.com/charge",
        headers: HTTP::Headers{
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{ENV["API_KEY"]?}"
        },
        body: payment_data.to_json
      )
      
      if response.status_code == 201
        result = JSON.parse(response.body)
        json_post(result)  # Returns 201 Created
      else
        bad_request("Payment failed")
      end
    rescue ex
      internal_server_error("Error: #{ex.message}")
    end
  end
end
```

## PATCH/PUT Request Example

```crystal
class SyncController < KothariAPI::Controller
  def update
    id = params["id"]?.to_i?
    return bad_request("ID required") unless id
    
    attrs = permit_body("name", "status")
    
    begin
      update_data = {
        "name" => attrs["name"]?.to_s,
        "status" => attrs["status"]?.to_s
      }
      
      response = HTTP::Client.patch(
        "https://api.example.com/resources/#{id}",
        headers: HTTP::Headers{"Content-Type" => "application/json"},
        body: update_data.to_json
      )
      
      if response.status_code == 200
        result = JSON.parse(response.body)
        json_update(result)  # Returns 200 OK
      else
        unprocessable_entity("Update failed")
      end
    rescue ex
      internal_server_error("Error: #{ex.message}")
    end
  end
end
```

## DELETE Request Example

```crystal
class ResourceController < KothariAPI::Controller
  def destroy
    id = params["id"]?.to_i?
    return bad_request("ID required") unless id
    
    begin
      response = HTTP::Client.delete(
        "https://api.example.com/resources/#{id}",
        headers: HTTP::Headers{"Authorization" => "Bearer #{ENV["API_KEY"]?}"}
      )
      
      if response.status_code == 200 || response.status_code == 204
        json_delete({message: "Deleted successfully"})  # Returns 200 OK
        # Or: json_delete  # Returns 204 No Content
      else
        internal_server_error("Delete failed")
      end
    rescue ex
      internal_server_error("Error: #{ex.message}")
    end
  end
end
```

## JSON Helper Methods Summary

| Method | HTTP Status | Use Case |
|--------|------------|----------|
| `json_get(data)` | 200 OK | GET requests, listing/showing resources |
| `json_post(data)` | 201 Created | POST requests, creating resources |
| `json_update(data)` | 200 OK | PUT/PATCH requests, updating resources |
| `json_patch(data)` | 200 OK | Alias for `json_update` |
| `json_delete(data)` | 200 OK | DELETE with response body |
| `json_delete()` | 204 No Content | DELETE without response body |

## Error Handling

Always wrap API calls in error handling:

```crystal
begin
  response = HTTP::Client.get("https://api.example.com/data")
  # ... process response
rescue ex : HTTP::Client::Error
  internal_server_error("Network error: #{ex.message}")
rescue ex : JSON::ParseException
  internal_server_error("Invalid JSON response")
rescue ex
  internal_server_error("Unexpected error: #{ex.message}")
end
```

## Best Practices

1. ✅ Always use `begin/rescue` for error handling
2. ✅ Check HTTP status codes before processing
3. ✅ Use appropriate JSON helper for the operation
4. ✅ Store API keys in environment variables
5. ✅ Set proper headers (Content-Type, Authorization)
6. ✅ Validate required parameters before making requests

