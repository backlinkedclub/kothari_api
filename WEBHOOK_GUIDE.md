# Webhook Helper Guide - KothariAPI Framework

## Overview

The webhook helper makes it easy to create webhook endpoints for any service (Twilio, Stripe, GitHub, PayPal, etc.). It automatically generates methods and routes with a simple, clean syntax.

## Quick Start

### 1. Create a Webhook Controller

```bash
kothari webhook twilio
```

This creates `app/controllers/twilio_webhook_controller.cr` with a template.

### 2. Add Webhook Methods

Edit the controller and use the `webhook()` macro:

```crystal
class TwilioWebhookController < KothariAPI::Controller
  webhook "incoming_call" do
    data = json_body
    from = data["From"]?.try &.to_s
    to = data["To"]?.try &.to_s
    
    # Your webhook processing logic here
    # Save to database, send notifications, etc.
    
    json({status: "received", from: from, to: to})
  end
  
  webhook "incoming_sms" do
    data = json_body
    message = data["Body"]?.try &.to_s
    
    # Process SMS webhook
    json({status: "sms_received", message: message})
  end
end
```

### 3. Generate Routes Automatically

```bash
kothari webhook:routes
```

This automatically adds routes to `config/routes.cr`:
- `POST /webhooks/twilio/incoming_call`
- `POST /webhooks/twilio/incoming_sms`

## How It Works

### The `webhook()` Macro

The `webhook()` macro is defined in `KothariAPI::Controller`. When you write:

```crystal
webhook "method_name" do
  # Your code
end
```

It automatically:
1. **Creates a method** with the specified name (e.g., `incoming_call`)
2. **Generates route path**: `/webhooks/<controller_base>/<method_name>`
3. **Uses POST method** (standard for webhooks)

### Route Generation

The `kothari webhook:routes` command:
1. Scans all `*_webhook_controller.cr` files
2. Finds all `webhook()` macro calls
3. Extracts method names
4. Generates routes: `POST /webhooks/<service>/<method>`
5. Adds them to `config/routes.cr`

## Examples

### Twilio Webhooks

```crystal
class TwilioWebhookController < KothariAPI::Controller
  webhook "incoming_call" do
    data = json_body
    # Process call webhook
    json({status: "ok"})
  end
  
  webhook "call_status" do
    data = json_body
    call_sid = data["CallSid"]?.try &.to_s
    status = data["CallStatus"]?.try &.to_s
    # Update call status in database
    json({status: "updated"})
  end
end
```

### Stripe Webhooks

```crystal
class StripeWebhookController < KothariAPI::Controller
  webhook "payment_succeeded" do
    data = json_body
    customer_id = data["customer"]?.try &.to_s
    amount = data["amount"]?.try &.as_i?
    
    # Process successful payment
    # Update user subscription, send confirmation email, etc.
    
    json({status: "processed"})
  end
  
  webhook "payment_failed" do
    data = json_body
    # Handle failed payment
    json({status: "logged"})
  end
  
  webhook "subscription_cancelled" do
    data = json_body
    # Handle subscription cancellation
    json({status: "cancelled"})
  end
end
```

### GitHub Webhooks

```crystal
class GithubWebhookController < KothariAPI::Controller
  webhook "push" do
    data = json_body
    repo = data["repository"]?.try &.["name"]?.try &.to_s
    commits = data["commits"]?.try &.as_a?
    
    # Process push event
    json({status: "received", repo: repo})
  end
  
  webhook "pull_request" do
    data = json_body
    action = data["action"]?.try &.to_s
    # Handle pull request events
    json({status: "processed", action: action})
  end
end
```

## Accessing Webhook Data

### JSON Body

All webhook data is available via `json_body`:

```crystal
webhook "event_name" do
  data = json_body  # Hash(String, JSON::Any)
  
  # Access nested data
  user_id = data["user"]?.try &.["id"]?.try &.as_i?
  email = data["user"]?.try &.["email"]?.try &.to_s
end
```

### URL Parameters

You can also access URL parameters:

```crystal
webhook "event" do
  # If route is /webhooks/service/event/:id
  id = params["id"]  # String from URL
end
```

## Complete Workflow Example

### Step 1: Create Webhook Controller

```bash
kothari webhook stripe
```

### Step 2: Implement Webhook Methods

```crystal
# app/controllers/stripe_webhook_controller.cr
class StripeWebhookController < KothariAPI::Controller
  webhook "payment_succeeded" do
    data = json_body
    customer_id = data["customer"]?.try &.to_s
    amount = data["amount"]?.try &.as_i?
    
    # Find user by Stripe customer ID
    user = User.find_by_stripe_id(customer_id)
    if user
      # Update user subscription
      user.update_subscription_status("active")
      json({status: "success"})
    else
      json({status: "user_not_found"}, status: 404)
    end
  end
end
```

### Step 3: Generate Routes

```bash
kothari webhook:routes
```

This adds to `config/routes.cr`:
```crystal
r.post "/webhooks/stripe/payment_succeeded", to: "stripe_webhook#payment_succeeded"
```

### Step 4: Configure External Service

In Stripe dashboard, set webhook URL to:
```
https://yourdomain.com/webhooks/stripe/payment_succeeded
```

## Benefits

1. **Automatic Route Generation** - No need to manually add routes
2. **Consistent URL Structure** - All webhooks follow `/webhooks/<service>/<event>` pattern
3. **Simple Syntax** - Just use `webhook "name" do ... end`
4. **Works with Any Service** - Not limited to specific providers
5. **Type-Safe** - Full Crystal type safety

## Advanced Usage

### Error Handling

```crystal
webhook "payment" do
  begin
    data = json_body
    # Process payment
    json({status: "ok"})
  rescue ex
    # Log error
    internal_server_error("Webhook processing failed: #{ex.message}")
  end
end
```

### Authentication/Verification

```crystal
webhook "payment" do
  # Verify webhook signature (Stripe example)
  signature = context.request.headers["Stripe-Signature"]?
  if verify_stripe_signature(signature, json_body.to_json)
    # Process webhook
    json({status: "ok"})
  else
    unauthorized("Invalid signature")
  end
end
```

### Database Operations

```crystal
webhook "user_created" do
  data = json_body
  email = data["email"]?.try &.to_s
  name = data["name"]?.try &.to_s
  
  # Create user in database
  user = User.create(
    email: email,
    name: name
  )
  
  json_post(user)
end
```

## Summary

The webhook helper provides a simple, powerful way to handle webhooks:

1. **Create**: `kothari webhook <service_name>`
2. **Implement**: Use `webhook "event_name" do ... end`
3. **Route**: Run `kothari webhook:routes`
4. **Deploy**: Configure external service to send to your endpoints

That's it! Your webhooks are ready to receive events from any service.
